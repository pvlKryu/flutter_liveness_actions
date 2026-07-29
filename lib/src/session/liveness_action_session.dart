import 'dart:async';

import '../analyzers/face_action_analyzer.dart';
import '../audit/audit_event_builder.dart';
import '../audit/audit_trail_recorder.dart';
import '../challenge/challenge_flow_controller.dart';
import '../config/challenge_config.dart';
import '../config/face_action_config.dart';
import '../config/performance_config.dart';
import '../guidance/guidance_message_builder.dart';
import '../lifecycle/liveness_session_lifecycle.dart';
import '../models/challenge_state.dart';
import '../models/challenge_step.dart';
import '../models/face_action_frame.dart';
import '../models/face_action_result.dart';
import '../models/face_action_type.dart';
import '../models/guidance_message.dart';
import '../models/liveness_diagnostics.dart';
import '../models/onboarding_audit_event.dart';
import '../performance/adaptive_performance_controller.dart';
import '../performance/frame_processing_controller.dart';
import '../quality/face_quality_gate.dart';
import '../security/multi_face_security_gate.dart';
import '../smoothing/face_jitter_filter.dart';
import '../version.dart';
import 'liveness_action_snapshot.dart';

/// Camera-agnostic orchestration of frame processing, challenge, guidance, and audit.
///
/// Apps supply normalized [FaceActionFrame] values (typically from ML Kit via
/// [MlKitFaceAdapter]). This session never touches the camera plugin directly.
///
/// Typical async camera loop:
/// ```dart
/// if (!session.acceptFrame(DateTime.now())) return;
/// session.markProcessingStarted();
/// final started = DateTime.now();
/// final frame = adapter.fromFaces(...);
/// final snapshot = session.completeFrame(
///   frame,
///   DateTime.now().difference(started),
/// );
/// ```
class LivenessActionSession {
  /// Creates a session with optional configs and challenge enablement.
  ///
  /// When [enableMultiFaceSecurityGate] is true (default) and challenges are
  /// enabled, `faceCount > 1` immediately locks the challenge as compromised.
  ///
  /// When [enableJitterFilter] is true (default), geometry is smoothed over a
  /// rolling window before analysis (see [FaceJitterFilter]).
  LivenessActionSession({
    FaceActionConfig faceConfig = const FaceActionConfig(),
    FaceChallengeConfig challengeConfig = const FaceChallengeConfig(),
    PerformanceConfig? performanceConfig,
    this.sessionId = 'session',
    this.enableChallenge = false,
    this.enableMultiFaceSecurityGate = true,
    this.enableJitterFilter = true,
    int jitterWindowSize = 5,
    String? packageVersionOverride,
    AuditTrailRecorder? trailRecorder,
    MultiFaceSecurityGate? multiFaceSecurityGate,
    FaceJitterFilter? jitterFilter,
  })  : packageVersionValue = packageVersionOverride ?? packageVersion,
        _adaptive = AdaptivePerformanceController(
          initialConfig: performanceConfig ?? PerformanceConfig.balanced(),
        ),
        _lifecycle = LivenessSessionLifecycle(),
        _guidanceBuilder = const GuidanceMessageBuilder(),
        _challengeConfig = challengeConfig,
        _faceConfig = faceConfig,
        _multiFaceGate = multiFaceSecurityGate ??
            (enableMultiFaceSecurityGate
                ? const MultiFaceSecurityGate()
                : null),
        _jitterFilter = jitterFilter ??
            (enableJitterFilter
                ? FaceJitterFilter(windowSize: jitterWindowSize)
                : null) {
    _frameController = FrameProcessingController(config: _adaptive.config);
    _qualityGate = FaceQualityGate(
      enableExtendedQualityChecks: _adaptive.config.enableExtendedQualityChecks,
    );
    _analyzer = FaceActionAnalyzer(
      config: _faceConfig,
      qualityGate: _qualityGate,
      guidanceBuilder: _guidanceBuilder,
      jitterFilter: _jitterFilter,
    );
    _startChallengeAndAudit(trailRecorder);
  }

  /// Demo / host session identifier for audit output.
  final String sessionId;

  /// Whether challenge evaluation runs on each accepted frame.
  final bool enableChallenge;

  /// Whether multi-face detections lock the challenge as compromised.
  final bool enableMultiFaceSecurityGate;

  /// Whether temporal geometry smoothing is applied before analysis.
  final bool enableJitterFilter;

  /// Package version string written into audit events.
  final String packageVersionValue;

  final AdaptivePerformanceController _adaptive;
  final LivenessSessionLifecycle _lifecycle;
  final GuidanceMessageBuilder _guidanceBuilder;
  final FaceChallengeConfig _challengeConfig;
  final FaceActionConfig _faceConfig;
  final MultiFaceSecurityGate? _multiFaceGate;
  final FaceJitterFilter? _jitterFilter;

  late FrameProcessingController _frameController;
  late FaceQualityGate _qualityGate;
  late FaceActionAnalyzer _analyzer;
  ChallengeFlowController? _challenge;
  late AuditEventBuilder _auditBuilder;
  StreamSubscription<dynamic>? _challengeSubscription;

  FaceActionResult? _latestResult;
  List<GuidanceMessage> _guidance = const <GuidanceMessage>[];
  bool _disposed = false;

  /// Latest analyzer result, if any.
  FaceActionResult? get latestResult => _latestResult;

  /// Current composed guidance messages.
  List<GuidanceMessage> get guidanceMessages => _guidance;

  /// Challenge controller when [enableChallenge] is true.
  ChallengeFlowController? get challenge => _challenge;

  /// Audit builder for the active session.
  AuditEventBuilder get auditBuilder => _auditBuilder;

  /// Active multi-face security gate, if enabled.
  MultiFaceSecurityGate? get multiFaceSecurityGate => _multiFaceGate;

  /// Active jitter filter, if enabled.
  FaceJitterFilter? get jitterFilter => _jitterFilter;

  /// Frame-processing diagnostics.
  LivenessDiagnostics get diagnostics => _frameController.diagnostics();

  /// Active performance configuration.
  PerformanceConfig get performanceConfig => _adaptive.config;

  /// Session lifecycle tracker.
  LivenessSessionLifecycle get lifecycle => _lifecycle;

  /// Whether the session may accept frames.
  bool get isActive => !_disposed && _lifecycle.isActive;

  /// Returns whether [timestamp] should be analyzed.
  bool acceptFrame(DateTime timestamp) {
    _ensureNotDisposed();
    if (!_lifecycle.isActive) {
      _frameController.markFrameDropped();
      return false;
    }
    return _frameController.shouldProcessFrame(timestamp);
  }

  /// Marks that async analysis work has started for an accepted frame.
  void markProcessingStarted() {
    _frameController.markProcessingStarted();
  }

  /// Releases busy state after a failed analysis attempt.
  ///
  /// Call when [markProcessingStarted] already ran but the frame could not be
  /// completed (unsupported format, conversion failure, detector error).
  /// Failed frames are counted as drops by default and are not counted as
  /// successfully processed.
  void markProcessingFailed({bool countAsDropped = true}) {
    _frameController.markProcessingFailed(countAsDropped: countAsDropped);
  }

  /// Records a dropped frame without releasing busy/in-flight state.
  ///
  /// Prefer [markProcessingFailed] after [markProcessingStarted].
  void markFrameDropped() {
    _frameController.markFrameDropped();
  }

  /// Completes analysis for [frame] and updates challenge / guidance / adaptive config.
  LivenessActionSnapshot completeFrame(
    FaceActionFrame frame,
    Duration processingDuration,
  ) {
    _ensureNotDisposed();
    _analyzer.updateDiagnostics(_frameController.diagnostics());
    final result = _analyzer.analyze(frame);
    _latestResult = result;

    if (_challenge != null && _multiFaceGate != null) {
      _multiFaceGate.applyFrame(
        frame,
        controller: _challenge,
        auditBuilder: _auditBuilder,
      );
    }

    if (_challenge != null &&
        !_challenge!.isCompromised &&
        result.quality.isAcceptable) {
      _auditBuilder.recordQualityGatePassed();
      final current = _challenge!.state.currentStep;
      if (current != null && _usesFrameEvaluation(current)) {
        _challenge!.processFrame(result.frame, now: frame.timestamp);
      } else {
        _challenge!.processSignal(result.signal, now: frame.timestamp);
      }
    }

    final step = _challenge?.state.currentStep;
    _guidance = _guidanceBuilder.compose(
      signal: result.signal,
      step: step,
      quality: result.quality,
      diagnostics: _frameController.diagnostics(),
      completed: _challenge?.state.completed ?? false,
    );

    final changed = _adaptive.observe(_frameController.diagnostics());
    if (changed) {
      _applyPerformanceConfig(_adaptive.config);
    }

    _frameController.markProcessingCompleted(
      processingDuration,
      processedAt: frame.timestamp,
    );

    return LivenessActionSnapshot(
      result: result,
      challengeState: _challenge?.state,
      guidance: _guidance,
      diagnostics: _frameController.diagnostics(),
      performanceConfig: _adaptive.config,
      performanceProfileChanged: changed,
    );
  }

  /// Convenience for synchronous / test pipelines (no async camera work).
  ///
  /// Combines [acceptFrame], [markProcessingStarted], and [completeFrame].
  LivenessActionSnapshot? processFrame(
    FaceActionFrame frame, {
    Duration processingDuration = Duration.zero,
  }) {
    if (!acceptFrame(frame.timestamp)) {
      return null;
    }
    markProcessingStarted();
    return completeFrame(frame, processingDuration);
  }

  /// Pauses frame acceptance (app backgrounded / camera stopped).
  void pause() {
    _lifecycle.pause();
    _frameController.pause();
  }

  /// Resumes frame acceptance.
  void resume() {
    if (_disposed) {
      return;
    }
    _lifecycle.resume();
    _frameController.resume();
  }

  /// Resets analyzers, challenge sequence, and frame counters.
  void reset() {
    _ensureNotDisposed();
    _analyzer.reset();
    _frameController.reset();
    _jitterFilter?.reset();
    _latestResult = null;
    _guidance = const <GuidanceMessage>[];
    _challengeSubscription?.cancel();
    _challenge?.dispose();
    _startChallengeAndAudit(null);
  }

  /// Builds a privacy-safe audit event from the current session state.
  OnboardingAuditEvent buildAuditEvent({DateTime? completedAt}) {
    _ensureNotDisposed();
    final signal = _latestResult?.signal;
    return _auditBuilder.build(
      challengeState: _challenge?.state ??
          const FaceChallengeState(
            steps: <FaceChallengeStep>[],
            currentStepIndex: -1,
            completed: false,
            failed: false,
            progress: 0,
          ),
      faceDetected: signal?.faceDetected ?? false,
      multipleFacesDetected: signal?.multipleFacesDetected ?? false,
      diagnostics: diagnostics,
      completedAt: completedAt,
      performanceConfig: performanceConfig,
    );
  }

  /// Releases session resources. Further processing throws.
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _challengeSubscription?.cancel();
    _challenge?.dispose();
    _lifecycle.dispose();
    _analyzer.reset();
    _frameController.reset();
  }

  void _startChallengeAndAudit(AuditTrailRecorder? trailRecorder) {
    if (enableChallenge) {
      _challenge = ChallengeFlowController(config: _challengeConfig);
      _auditBuilder = AuditEventBuilder(
        sessionId: sessionId,
        sequenceId: _challenge!.sequence.sequenceId,
        challengeNonce: _challenge!.sequence.challengeNonce,
        packageVersion: packageVersionValue,
        trailRecorder: trailRecorder,
      );
      _challengeSubscription =
          _challenge!.events.listen(_auditBuilder.recordChallengeEvent);
    } else {
      _challenge = null;
      _auditBuilder = AuditEventBuilder(
        sessionId: sessionId,
        sequenceId: 'no-challenge',
        packageVersion: packageVersionValue,
        trailRecorder: trailRecorder,
      );
    }
  }

  void _applyPerformanceConfig(PerformanceConfig config) {
    _frameController.updateConfig(config);
    _qualityGate = FaceQualityGate(
      enableExtendedQualityChecks: config.enableExtendedQualityChecks,
    );
    _analyzer = FaceActionAnalyzer(
      config: _faceConfig,
      qualityGate: _qualityGate,
      guidanceBuilder: _guidanceBuilder,
      jitterFilter: _jitterFilter,
    );
  }

  bool _usesFrameEvaluation(FaceChallengeStep step) {
    switch (step.type) {
      case FaceActionType.followTarget:
      case FaceActionType.followTargetPath:
      case FaceActionType.moveToTopLeft:
      case FaceActionType.moveToTopRight:
      case FaceActionType.moveToBottomLeft:
      case FaceActionType.moveToBottomRight:
        return true;
      case FaceActionType.moveToCenter:
        // Prefer geometry when explicit target zones are present.
        return step.targetZones != null && step.targetZones!.isNotEmpty;
      case FaceActionType.centerFace:
      case FaceActionType.blinkOnce:
      case FaceActionType.turnHeadLeft:
      case FaceActionType.turnHeadRight:
      case FaceActionType.holdStill:
      case FaceActionType.smile:
        return false;
    }
  }

  void _ensureNotDisposed() {
    if (_disposed) {
      throw StateError('LivenessActionSession has been disposed.');
    }
  }
}

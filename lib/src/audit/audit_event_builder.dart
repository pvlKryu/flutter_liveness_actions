import '../config/performance_config.dart';
import '../models/challenge_event.dart';
import '../models/challenge_state.dart';
import '../models/challenge_step.dart';
import '../models/liveness_diagnostics.dart';
import '../models/onboarding_audit_event.dart';
import '../privacy/privacy_guard.dart';
import '../security/security_violation_code.dart';
import 'audit_trail_recorder.dart';

/// Builds privacy-safe onboarding audit events with optional trail support.
class AuditEventBuilder {
  /// Creates a builder for a challenge session audit trail.
  AuditEventBuilder({
    required this.sessionId,
    required this.sequenceId,
    required this.packageVersion,
    PrivacyGuard? privacyGuard,
    AuditTrailRecorder? trailRecorder,
    DateTime? startedAt,
    this.challengeNonce,
  })  : _privacyGuard = privacyGuard ?? const PrivacyGuard(),
        _trailRecorder = trailRecorder ?? AuditTrailRecorder(),
        _startedAt = startedAt ?? DateTime.now() {
    _trailRecorder.record(AuditTrailEventType.sessionStarted);
  }

  /// Session identifier for the demo flow.
  final String sessionId;

  /// Challenge sequence identifier.
  final String sequenceId;

  /// Optional demo nonce for randomized sequences.
  final String? challengeNonce;

  /// Package version string embedded in audit output.
  final String packageVersion;

  final PrivacyGuard _privacyGuard;
  final AuditTrailRecorder _trailRecorder;
  final DateTime _startedAt;
  SecurityViolationCode? _securityViolation;

  /// Underlying audit trail recorder.
  AuditTrailRecorder get trailRecorder => _trailRecorder;

  /// Last recorded security violation, if any.
  SecurityViolationCode? get securityViolation => _securityViolation;

  /// Records that the camera is ready for local analysis.
  void recordCameraReady() {
    _trailRecorder.record(AuditTrailEventType.cameraReady);
  }

  /// Records that the quality gate accepted a frame.
  void recordQualityGatePassed() {
    _trailRecorder.record(AuditTrailEventType.qualityGatePassed);
  }

  /// Records a security fail-safe (e.g. multi-face) in the audit trail.
  void recordSecurityViolation(
    SecurityViolationCode code, {
    int? faceCount,
    DateTime? timestamp,
  }) {
    _securityViolation = code;
    _trailRecorder.recordSecurityViolation(
      code: code.name,
      faceCount: faceCount,
      timestamp: timestamp,
    );
  }

  /// Records active performance profile and measured latency / FPS.
  void recordPerformanceContext({
    required PerformanceConfig performanceConfig,
    required LivenessDiagnostics diagnostics,
    DateTime? timestamp,
  }) {
    final effectiveFps = diagnostics.averageProcessingMs > 0
        ? 1000.0 / diagnostics.averageProcessingMs
        : null;
    _trailRecorder.recordPerformanceContext(
      profile: performanceConfig.profile.name,
      targetProcessingFps: performanceConfig.targetProcessingFps,
      averageProcessingMs: diagnostics.averageProcessingMs,
      effectiveProcessingFps: effectiveFps,
      processedFrames: diagnostics.processedFrames,
      droppedFrames: diagnostics.droppedFrames,
      timestamp: timestamp,
    );
  }

  /// Records a [FaceChallengeEvent] in the audit trail.
  void recordChallengeEvent(FaceChallengeEvent event) {
    switch (event.type) {
      case FaceChallengeEventType.challengeStarted:
        _trailRecorder.record(AuditTrailEventType.challengeStarted);
      case FaceChallengeEventType.stepPassed:
        _trailRecorder.record(
          AuditTrailEventType.stepPassed,
          stepId: event.stepId,
          message: event.message,
        );
      case FaceChallengeEventType.stepFailed:
        _trailRecorder.record(
          AuditTrailEventType.stepFailed,
          stepId: event.stepId,
          message: event.message,
          metadata: <String, Object?>{
            'failureReason': event.failureReason.name,
          },
        );
      case FaceChallengeEventType.retryRequested:
        _trailRecorder.record(
          AuditTrailEventType.retryRequested,
          stepId: event.stepId,
        );
      case FaceChallengeEventType.challengeCompleted:
        _trailRecorder.record(AuditTrailEventType.challengeCompleted);
      case FaceChallengeEventType.challengeFailed:
        _trailRecorder.record(
          AuditTrailEventType.stepFailed,
          stepId: event.stepId,
          message: 'challenge_failed',
          metadata: <String, Object?>{
            'failureReason': event.failureReason.name,
          },
        );
      case FaceChallengeEventType.challengeCompromised:
        final code =
            event.securityViolation ?? SecurityViolationCode.multiFaceDetected;
        _securityViolation = code;
        _trailRecorder.recordSecurityViolation(
          code: code.name,
          timestamp: event.timestamp,
          message: event.message ?? code.name,
        );
    }
  }

  /// Records a diagnostics summary snapshot.
  void recordDiagnosticsSummary(LivenessDiagnostics diagnostics) {
    _trailRecorder.record(
      AuditTrailEventType.diagnosticsSummary,
      metadata: diagnostics.toJson(),
    );
  }

  /// Builds a privacy-safe [OnboardingAuditEvent] from challenge state.
  ///
  /// [performanceConfig] enriches the `performance` JSON block with the active
  /// profile. Privacy flags are immutable package guarantees:
  /// `derivedSignalsOnly: true`, `rawImagesStored: false`.
  OnboardingAuditEvent build({
    required FaceChallengeState challengeState,
    required bool faceDetected,
    required bool multipleFacesDetected,
    required LivenessDiagnostics diagnostics,
    DateTime? completedAt,
    PerformanceConfig? performanceConfig,
  }) {
    recordDiagnosticsSummary(diagnostics);
    if (performanceConfig != null) {
      recordPerformanceContext(
        performanceConfig: performanceConfig,
        diagnostics: diagnostics,
      );
    }

    final violation = _securityViolation ?? challengeState.securityViolation;
    final performance = _buildPerformanceMap(
      performanceConfig: performanceConfig,
      diagnostics: diagnostics,
    );

    return OnboardingAuditEvent(
      sessionId: sessionId,
      sequenceId: sequenceId,
      challengeNonce: challengeNonce,
      startedAt: _startedAt,
      completedAt: completedAt,
      packageVersion: packageVersion,
      faceDetected: faceDetected,
      multipleFacesDetected: multipleFacesDetected,
      steps: challengeState.steps.map(_stepToMap).toList(growable: false),
      events: _trailRecorder.toJsonList(),
      rawImagesStored: false,
      identityDecision: 'not_performed',
      creditDecision: 'not_performed',
      demoOnly: true,
      diagnostics: diagnostics.toJson(),
      privacy: _privacyGuard.auditPrivacyFlags(),
      performance: performance,
      securityViolation: violation,
    );
  }

  Map<String, Object?> _buildPerformanceMap({
    required PerformanceConfig? performanceConfig,
    required LivenessDiagnostics diagnostics,
  }) {
    final effectiveFps = diagnostics.averageProcessingMs > 0
        ? 1000.0 / diagnostics.averageProcessingMs
        : null;
    return <String, Object?>{
      'profile': performanceConfig?.profile.name ??
          diagnostics.recommendedPerformanceProfile.name,
      'targetProcessingFps': performanceConfig?.targetProcessingFps ??
          diagnostics.targetProcessingFps,
      'averageProcessingMs': diagnostics.averageProcessingMs,
      'effectiveProcessingFps': effectiveFps,
      'processedFrames': diagnostics.processedFrames,
      'droppedFrames': diagnostics.droppedFrames,
    };
  }

  Map<String, Object?> _stepToMap(FaceChallengeStep step) {
    final durationMs = step.startedAt == null || step.completedAt == null
        ? null
        : step.completedAt!.difference(step.startedAt!).inMilliseconds;
    return <String, Object?>{
      'id': step.id,
      'type': step.type.name,
      'status': step.status.name,
      'durationMs': durationMs,
      'retryCount': step.retryCount,
      'failureReason': step.failureReason.name,
      if (step.targetZones != null) 'targetCount': step.targetZones!.length,
      if (step.targetZones != null)
        'targetPathIds':
            step.targetZones!.map((z) => z.id).toList(growable: false),
    };
  }
}

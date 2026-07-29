import '../config/face_action_config.dart';
import '../guidance/guidance_message_builder.dart';
import '../models/face_action_frame.dart';
import '../models/face_action_result.dart';
import '../models/face_action_signal.dart';
import '../models/face_position_status.dart';
import '../models/liveness_diagnostics.dart';
import '../performance/performance_profile.dart';
import '../quality/face_quality_gate.dart';
import '../smoothing/face_jitter_filter.dart';
import 'blink_detector.dart';
import 'face_position_analyzer.dart';
import 'head_movement_detector.dart';

/// Orchestrates detectors and quality checks into a [FaceActionResult].
class FaceActionAnalyzer {
  /// Creates an analyzer with optional detector and gate dependencies.
  ///
  /// When [jitterFilter] is provided, geometry metrics are temporally smoothed
  /// before position / movement / quality evaluation.
  FaceActionAnalyzer({
    FaceActionConfig config = const FaceActionConfig(),
    BlinkDetector? blinkDetector,
    HeadMovementDetector? headMovementDetector,
    FacePositionAnalyzer? positionAnalyzer,
    FaceQualityGate? qualityGate,
    GuidanceMessageBuilder? guidanceBuilder,
    FaceJitterFilter? jitterFilter,
  })  : _config = config,
        _blinkDetector = blinkDetector ?? BlinkDetector(config: config),
        _headMovementDetector =
            headMovementDetector ?? HeadMovementDetector(config: config),
        _positionAnalyzer =
            positionAnalyzer ?? FacePositionAnalyzer(config: config),
        _qualityGate = qualityGate ?? FaceQualityGate(),
        _guidanceBuilder = guidanceBuilder ?? const GuidanceMessageBuilder(),
        _jitterFilter = jitterFilter;

  final FaceActionConfig _config;
  final BlinkDetector _blinkDetector;
  final HeadMovementDetector _headMovementDetector;
  final FacePositionAnalyzer _positionAnalyzer;
  final FaceQualityGate _qualityGate;
  final GuidanceMessageBuilder _guidanceBuilder;
  final FaceJitterFilter? _jitterFilter;

  int _holdStillFrames = 0;
  LivenessDiagnostics _diagnostics = const LivenessDiagnostics(
    targetProcessingFps: 12,
    recommendedPerformanceProfile: PerformanceProfile.balanced,
  );

  /// Updates diagnostics attached to subsequent [analyze] results.
  void updateDiagnostics(LivenessDiagnostics diagnostics) {
    _diagnostics = diagnostics;
  }

  /// Analyzes a normalized [frame] into derived interaction signals.
  FaceActionResult analyze(FaceActionFrame frame) {
    final input = _jitterFilter?.filter(frame) ?? frame;
    final position = _positionAnalyzer.analyze(input);
    final quality = _qualityGate.evaluate(input);
    final movement = _headMovementDetector.detect(
      yaw: input.headEulerAngleY,
      roll: input.headEulerAngleZ,
    );
    final eyesOpen =
        (input.leftEyeOpenProbability ?? 0) >= _config.eyeOpenThreshold &&
            (input.rightEyeOpenProbability ?? 0) >= _config.eyeOpenThreshold;
    final blinkDetected = _blinkDetector.update(
      leftEyeOpenProbability: input.leftEyeOpenProbability,
      rightEyeOpenProbability: input.rightEyeOpenProbability,
      timestamp: input.timestamp,
    );

    final stillNow = !movement.left && !movement.right && !movement.tilted;
    _holdStillFrames = stillNow ? _holdStillFrames + 1 : 0;

    var signal = FaceActionSignal(
      faceDetected: input.faceDetected,
      multipleFacesDetected: input.faceCount > 1,
      singleFaceDetected: input.faceCount == 1,
      faceCentered: position == FacePositionStatus.centered,
      faceTooClose: position == FacePositionStatus.tooClose,
      faceTooFar: position == FacePositionStatus.tooFar,
      faceOutOfFrame: position == FacePositionStatus.outOfFrame,
      blinkDetected: blinkDetected,
      eyesOpen: eyesOpen,
      headTurnedLeft: movement.left,
      headTurnedRight: movement.right,
      headTilted: movement.tilted,
      holdStill: _holdStillFrames >= _config.requiredStableFrames,
      smileDetected: (input.smilingProbability ?? 0) >= _config.smileThreshold,
      qualityStatus: quality.status,
      positionStatus: position,
      warnings: quality.warnings.map((w) => w.name).toList(growable: false),
    );

    final guidance = _guidanceBuilder.compose(
      signal: signal,
      quality: quality,
      diagnostics: _diagnostics,
    );
    signal = FaceActionSignal(
      faceDetected: signal.faceDetected,
      multipleFacesDetected: signal.multipleFacesDetected,
      singleFaceDetected: signal.singleFaceDetected,
      faceCentered: signal.faceCentered,
      faceTooClose: signal.faceTooClose,
      faceTooFar: signal.faceTooFar,
      faceOutOfFrame: signal.faceOutOfFrame,
      blinkDetected: signal.blinkDetected,
      eyesOpen: signal.eyesOpen,
      headTurnedLeft: signal.headTurnedLeft,
      headTurnedRight: signal.headTurnedRight,
      headTilted: signal.headTilted,
      holdStill: signal.holdStill,
      smileDetected: signal.smileDetected,
      qualityStatus: signal.qualityStatus,
      positionStatus: signal.positionStatus,
      guidanceMessages: guidance,
      warnings: signal.warnings,
    );

    return FaceActionResult(
      frame: input,
      signal: signal,
      quality: quality,
      diagnostics: _diagnostics,
      processedAt: DateTime.now(),
    );
  }

  /// Resets blink / hold-still / quality / jitter state.
  void reset() {
    _holdStillFrames = 0;
    _blinkDetector.reset();
    _qualityGate.reset();
    _jitterFilter?.reset();
  }
}

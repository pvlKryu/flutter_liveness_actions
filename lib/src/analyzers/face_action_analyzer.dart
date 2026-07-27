import '../config/face_action_config.dart';
import '../guidance/guidance_message_builder.dart';
import '../models/face_action_frame.dart';
import '../models/face_action_result.dart';
import '../models/face_action_signal.dart';
import '../models/face_position_status.dart';
import '../models/liveness_diagnostics.dart';
import '../performance/performance_profile.dart';
import '../quality/face_quality_gate.dart';
import 'blink_detector.dart';
import 'face_position_analyzer.dart';
import 'head_movement_detector.dart';

/// face action analyzer.
class FaceActionAnalyzer {
  /// Creates an analyzer with optional detector and gate dependencies.
  FaceActionAnalyzer({
    FaceActionConfig config = const FaceActionConfig(),
    BlinkDetector? blinkDetector,
    HeadMovementDetector? headMovementDetector,
    FacePositionAnalyzer? positionAnalyzer,
    FaceQualityGate? qualityGate,
    GuidanceMessageBuilder? guidanceBuilder,
  })  : _config = config,
        _blinkDetector = blinkDetector ?? BlinkDetector(config: config),
        _headMovementDetector =
            headMovementDetector ?? HeadMovementDetector(config: config),
        _positionAnalyzer =
            positionAnalyzer ?? FacePositionAnalyzer(config: config),
        _qualityGate = qualityGate ?? FaceQualityGate(),
        _guidanceBuilder = guidanceBuilder ?? const GuidanceMessageBuilder();

  ///  config.
  final FaceActionConfig _config;

  ///  blink detector.
  final BlinkDetector _blinkDetector;

  ///  head movement detector.
  final HeadMovementDetector _headMovementDetector;

  ///  position analyzer.
  final FacePositionAnalyzer _positionAnalyzer;

  ///  quality gate.
  final FaceQualityGate _qualityGate;

  ///  guidance builder.
  final GuidanceMessageBuilder _guidanceBuilder;

  int _holdStillFrames = 0;

  /// analyze.
  FaceActionResult analyze(FaceActionFrame frame) {
    final position = _positionAnalyzer.analyze(frame);
    final quality = _qualityGate.evaluate(frame);
    final movement = _headMovementDetector.detect(
      yaw: frame.headEulerAngleY,
      roll: frame.headEulerAngleZ,
    );
    final eyesOpen =
        (frame.leftEyeOpenProbability ?? 0) >= _config.eyeOpenThreshold &&
            (frame.rightEyeOpenProbability ?? 0) >= _config.eyeOpenThreshold;
    final blinkDetected = _blinkDetector.update(
      leftEyeOpenProbability: frame.leftEyeOpenProbability,
      rightEyeOpenProbability: frame.rightEyeOpenProbability,
      timestamp: frame.timestamp,
    );

    final stillNow = !movement.left && !movement.right && !movement.tilted;
    _holdStillFrames = stillNow ? _holdStillFrames + 1 : 0;

    var signal = FaceActionSignal(
      faceDetected: frame.faceDetected,
      multipleFacesDetected: frame.faceCount > 1,
      singleFaceDetected: frame.faceCount == 1,
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
      smileDetected: (frame.smilingProbability ?? 0) > 0.7,
      qualityStatus: quality.status,
      positionStatus: position,
    );
    final guidance = _guidanceBuilder.fromSignal(signal);
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
    );

    return FaceActionResult(
      frame: frame,
      signal: signal,
      quality: quality,
      diagnostics: const LivenessDiagnostics(
        targetProcessingFps: 12,
        recommendedPerformanceProfile: PerformanceProfile.balanced,
      ),
      processedAt: DateTime.now(),
    );
  }
}

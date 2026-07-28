import '../models/challenge_step.dart';
import '../models/face_action_frame.dart';
import '../models/face_action_signal.dart';
import '../models/face_action_type.dart';
import '../target/face_target_position.dart';
import '../target/target_zone.dart';

/// Evaluates whether a derived signal / frame satisfies a challenge step.
///
/// Advanced API — most apps should use [ChallengeFlowController] or
/// [LivenessActionSession] instead of calling this directly.
class ChallengeStepEvaluator {
  /// Creates a step evaluator.
  const ChallengeStepEvaluator();

  /// Returns `true` when [signal] completes [step] for signal-based types.
  ///
  /// Target-path steps should be evaluated via [evaluateFrame] /
  /// [ChallengeFlowController.processFrame].
  bool evaluate(FaceChallengeStep step, FaceActionSignal signal) {
    switch (step.type) {
      case FaceActionType.centerFace:
      case FaceActionType.moveToCenter:
        return signal.faceCentered;
      case FaceActionType.blinkOnce:
        return signal.blinkDetected;
      case FaceActionType.turnHeadLeft:
        return signal.headTurnedLeft;
      case FaceActionType.turnHeadRight:
        return signal.headTurnedRight;
      case FaceActionType.holdStill:
        return signal.holdStill;
      case FaceActionType.smile:
        return signal.smileDetected;
      case FaceActionType.followTarget:
      case FaceActionType.followTargetPath:
        return false;
      case FaceActionType.moveToTopLeft:
      case FaceActionType.moveToTopRight:
      case FaceActionType.moveToBottomLeft:
      case FaceActionType.moveToBottomRight:
        return false;
    }
  }

  /// Evaluates geometry-based steps using [frame].
  bool evaluateFrame(FaceChallengeStep step, FaceActionFrame frame) {
    switch (step.type) {
      case FaceActionType.moveToTopLeft:
        return _insidePreset(frame, 0.28, 0.28);
      case FaceActionType.moveToTopRight:
        return _insidePreset(frame, 0.72, 0.28);
      case FaceActionType.moveToBottomLeft:
        return _insidePreset(frame, 0.28, 0.72);
      case FaceActionType.moveToBottomRight:
        return _insidePreset(frame, 0.72, 0.72);
      case FaceActionType.moveToCenter:
      case FaceActionType.centerFace:
        return _insidePreset(frame, 0.5, 0.5, radius: 0.16);
      case FaceActionType.followTarget:
        final zones = step.targetZones;
        if (zones == null || zones.isEmpty) {
          return false;
        }
        return _insideZone(frame, zones.first);
      case FaceActionType.followTargetPath:
        return false;
      default:
        return false;
    }
  }

  bool _insidePreset(
    FaceActionFrame frame,
    double x,
    double y, {
    double radius = 0.14,
  }) {
    return _insideZone(
      frame,
      TargetZone(id: 'preset', centerX: x, centerY: y, radius: radius),
    );
  }

  bool _insideZone(FaceActionFrame frame, TargetZone zone) {
    final position = FaceTargetPosition.fromFrame(frame);
    if (!position.isValid) {
      return false;
    }
    return position.distanceToPoint(zone.centerX, zone.centerY) <= zone.radius;
  }
}

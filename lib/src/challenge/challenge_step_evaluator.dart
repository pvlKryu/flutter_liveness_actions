import '../models/challenge_step.dart';
import '../models/face_action_signal.dart';
import '../models/face_action_type.dart';

/// challenge step evaluator.
class ChallengeStepEvaluator {
  /// Creates an instance with optional overrides.
  const ChallengeStepEvaluator();

  /// evaluate.
  bool evaluate(FaceChallengeStep step, FaceActionSignal signal) {
    switch (step.type) {
      case FaceActionType.centerFace:
        return signal.faceCentered;
      case FaceActionType.blinkOnce:
        return signal.blinkDetected;
      case FaceActionType.turnHeadLeft:
        return signal.headTurnedLeft;
      case FaceActionType.turnHeadRight:
        return signal.headTurnedRight;
      case FaceActionType.holdStill:
        return signal.holdStill;
    }
  }
}

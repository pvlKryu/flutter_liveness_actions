import '../models/challenge_step.dart';
import '../models/face_action_signal.dart';
import '../models/face_action_type.dart';

/// Evaluates whether a derived [FaceActionSignal] satisfies a challenge step.
///
/// Advanced API — most apps should use [ChallengeFlowController] or
/// [LivenessActionSession] instead of calling this directly.
class ChallengeStepEvaluator {
  /// Creates a step evaluator.
  const ChallengeStepEvaluator();

  /// Returns `true` when [signal] completes [step].
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

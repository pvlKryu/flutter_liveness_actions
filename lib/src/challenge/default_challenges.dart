import '../models/challenge_sequence.dart';
import '../models/challenge_step.dart';
import '../models/face_action_type.dart';

/// default challenges.
class DefaultChallenges {
  /// default sequence.
  static FaceChallengeSequence defaultSequence() {
    const timeout = Duration(seconds: 8);
    return const FaceChallengeSequence(
      sequenceId: 'default-sequence',
      steps: <FaceChallengeStep>[
        FaceChallengeStep(
          id: 'step-center',
          type: FaceActionType.centerFace,
          instruction: 'Center your face in the frame.',
          status: ChallengeStepStatus.pending,
          timeout: timeout,
        ),
        FaceChallengeStep(
          id: 'step-blink',
          type: FaceActionType.blinkOnce,
          instruction: 'Blink once.',
          status: ChallengeStepStatus.pending,
          timeout: timeout,
        ),
        FaceChallengeStep(
          id: 'step-left',
          type: FaceActionType.turnHeadLeft,
          instruction: 'Turn your head left.',
          status: ChallengeStepStatus.pending,
          timeout: timeout,
        ),
        FaceChallengeStep(
          id: 'step-right',
          type: FaceActionType.turnHeadRight,
          instruction: 'Turn your head right.',
          status: ChallengeStepStatus.pending,
          timeout: timeout,
        ),
        FaceChallengeStep(
          id: 'step-still',
          type: FaceActionType.holdStill,
          instruction: 'Hold still.',
          status: ChallengeStepStatus.pending,
          timeout: timeout,
        ),
      ],
    );
  }
}

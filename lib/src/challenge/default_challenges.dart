import '../models/challenge_sequence.dart';
import '../models/challenge_step.dart';
import '../models/face_action_type.dart';
import '../target/target_path_factory.dart';

/// Built-in challenge sequence presets.
class DefaultChallenges {
  /// Alias for [basic].
  static FaceChallengeSequence defaultSequence() => basic();

  /// Standard demo sequence (unchanged from 1.0.x intent).
  static FaceChallengeSequence basic() {
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

  /// Lightweight sequence for lower-end Android devices.
  static FaceChallengeSequence lowEndFriendly() {
    const timeout = Duration(seconds: 8);
    return const FaceChallengeSequence(
      sequenceId: 'low-end-friendly',
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
          id: 'step-still',
          type: FaceActionType.holdStill,
          instruction: 'Hold still.',
          status: ChallengeStepStatus.pending,
          timeout: timeout,
        ),
      ],
    );
  }

  /// Extended demo sequence including smile and a simple follow-the-dot path.
  static FaceChallengeSequence extended() {
    const timeout = Duration(seconds: 10);
    final targets = DefaultTargetPaths.simpleCross();
    return FaceChallengeSequence(
      sequenceId: 'extended-sequence',
      steps: <FaceChallengeStep>[
        const FaceChallengeStep(
          id: 'step-center',
          type: FaceActionType.centerFace,
          instruction: 'Center your face in the frame.',
          status: ChallengeStepStatus.pending,
          timeout: timeout,
        ),
        const FaceChallengeStep(
          id: 'step-blink',
          type: FaceActionType.blinkOnce,
          instruction: 'Blink once.',
          status: ChallengeStepStatus.pending,
          timeout: timeout,
        ),
        const FaceChallengeStep(
          id: 'step-smile',
          type: FaceActionType.smile,
          instruction: 'Smile.',
          status: ChallengeStepStatus.pending,
          timeout: timeout,
        ),
        const FaceChallengeStep(
          id: 'step-left',
          type: FaceActionType.turnHeadLeft,
          instruction: 'Turn your head left.',
          status: ChallengeStepStatus.pending,
          timeout: timeout,
        ),
        const FaceChallengeStep(
          id: 'step-right',
          type: FaceActionType.turnHeadRight,
          instruction: 'Turn your head right.',
          status: ChallengeStepStatus.pending,
          timeout: timeout,
        ),
        FaceChallengeStep(
          id: 'step-follow-target',
          type: FaceActionType.followTargetPath,
          instruction: 'Follow the moving target with your face.',
          status: ChallengeStepStatus.pending,
          timeout: const Duration(seconds: 40),
          targetZones: targets,
        ),
        const FaceChallengeStep(
          id: 'step-still',
          type: FaceActionType.holdStill,
          instruction: 'Hold still.',
          status: ChallengeStepStatus.pending,
          timeout: timeout,
        ),
      ],
    );
  }

  /// Follow-the-dot only sequence using [DefaultTargetPaths.simpleCross].
  static FaceChallengeSequence followTargetSimple() {
    return FaceChallengeSequence(
      sequenceId: 'follow-target-simple',
      steps: <FaceChallengeStep>[
        FaceChallengeStep(
          id: 'step-follow',
          type: FaceActionType.followTargetPath,
          instruction: 'Follow the target with your face center.',
          status: ChallengeStepStatus.pending,
          timeout: const Duration(seconds: 40),
          targetZones: DefaultTargetPaths.simpleCross(),
        ),
      ],
    );
  }
}

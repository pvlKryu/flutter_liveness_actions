import 'dart:math';

import '../config/challenge_config.dart';
import '../models/challenge_sequence.dart';
import '../models/challenge_step.dart';
import '../models/face_action_type.dart';
import 'default_challenges.dart';

/// challenge sequence factory.
class ChallengeSequenceFactory {
  /// Creates an instance with optional overrides.
  const ChallengeSequenceFactory();

  /// create.
  FaceChallengeSequence create(FaceChallengeConfig config) {
    if (!config.randomize) {
      return DefaultChallenges.defaultSequence();
    }
    final random = Random(config.seed);
    final steps = List<FaceActionType>.from(config.allowedSteps)
      ..shuffle(random);
    final selected = steps.take(config.maxSteps).toList(growable: false);
    return FaceChallengeSequence(
      sequenceId: 'sequence-${DateTime.now().millisecondsSinceEpoch}',
      challengeNonce: 'nonce-${random.nextInt(999999)}',
      seed: config.seed,
      steps: selected
          .asMap()
          .entries
          .map(
            (entry) => FaceChallengeStep(
              id: 'step-${entry.key}',
              type: entry.value,
              instruction: _instructionFor(entry.value),
              status: ChallengeStepStatus.pending,
              timeout: config.stepTimeout,
            ),
          )
          .toList(growable: false),
    );
  }

  ///  instruction for.
  String _instructionFor(FaceActionType action) {
    switch (action) {
      case FaceActionType.centerFace:
        return 'Center your face in the frame.';
      case FaceActionType.blinkOnce:
        return 'Blink once.';
      case FaceActionType.turnHeadLeft:
        return 'Turn your head left.';
      case FaceActionType.turnHeadRight:
        return 'Turn your head right.';
      case FaceActionType.holdStill:
        return 'Hold still.';
    }
  }
}

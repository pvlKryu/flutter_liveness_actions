import 'dart:math';

import '../config/challenge_config.dart';
import '../models/challenge_sequence.dart';
import '../models/challenge_step.dart';
import '../models/face_action_type.dart';
import '../guidance/guidance_catalog.dart';
import '../target/target_path_factory.dart';
import '../target/target_zone.dart';
import 'default_challenges.dart';

/// Builds default or randomized challenge sequences.
class ChallengeSequenceFactory {
  /// Creates a challenge sequence factory.
  const ChallengeSequenceFactory();

  /// Creates a challenge sequence from [config].
  FaceChallengeSequence create(FaceChallengeConfig config) {
    if (!config.randomize) {
      return DefaultChallenges.defaultSequence();
    }

    final seed = config.seed ?? DateTime.now().millisecondsSinceEpoch;
    final random = Random(seed);
    final selected = _selectSteps(config, random);
    final nonce = _nonceFor(seed, random);

    return FaceChallengeSequence(
      sequenceId: '${config.sequenceIdPrefix}-$seed',
      challengeNonce: nonce,
      seed: seed,
      steps: selected
          .asMap()
          .entries
          .map(
            (entry) => FaceChallengeStep(
              id: 'step-${entry.key}',
              type: entry.value,
              instruction: GuidanceCatalog.instructionFor(entry.value),
              status: ChallengeStepStatus.pending,
              timeout: entry.value == FaceActionType.followTargetPath
                  ? const Duration(seconds: 40)
                  : config.stepTimeout,
              targetZones: entry.value == FaceActionType.followTargetPath
                  ? _generateTargetZones(config, seed)
                  : null,
            ),
          )
          .toList(growable: false),
    );
  }

  List<FaceActionType> _selectSteps(
    FaceChallengeConfig config,
    Random random,
  ) {
    final pool = List<FaceActionType>.from(config.allowedSteps);
    if (pool.isEmpty) {
      return const <FaceActionType>[];
    }

    final selected = <FaceActionType>[];
    if (config.requireCenterFaceFirst &&
        pool.contains(FaceActionType.centerFace)) {
      selected.add(FaceActionType.centerFace);
      if (!config.allowDuplicateSteps) {
        pool.remove(FaceActionType.centerFace);
      }
    }

    pool.shuffle(random);
    for (final step in pool) {
      if (selected.length >= config.maxSteps) {
        break;
      }
      if (!config.allowDuplicateSteps && selected.contains(step)) {
        continue;
      }
      selected.add(step);
    }
    return selected;
  }

  List<TargetZone> _generateTargetZones(FaceChallengeConfig config, int seed) {
    const factory = TargetPathFactory();
    if (config.useLowEndFriendlyTargets) {
      return factory.lowEndFriendly();
    }
    if (config.randomizeTargetPath) {
      return factory.randomized(
        seed: config.targetSeed ?? seed,
        maxSteps: config.maxTargetSteps,
      );
    }
    return factory.simpleCross();
  }

  String _nonceFor(int seed, Random random) {
    return 'nonce-${seed.toRadixString(16)}-${random.nextInt(999999)}';
  }
}

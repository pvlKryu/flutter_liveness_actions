import '../models/face_action_type.dart';

/// face challenge config.
class FaceChallengeConfig {
  /// Creates an instance with optional overrides.
  const FaceChallengeConfig({
    this.stepTimeout = const Duration(seconds: 8),
    this.maxRetriesPerStep = 2,
    this.randomize = false,
    this.seed,
    this.allowedSteps = const <FaceActionType>[
      FaceActionType.centerFace,
      FaceActionType.blinkOnce,
      FaceActionType.turnHeadLeft,
      FaceActionType.turnHeadRight,
      FaceActionType.holdStill,
    ],
    this.maxSteps = 5,
  });

  /// step timeout.
  final Duration stepTimeout;

  /// max retries per step.
  final int maxRetriesPerStep;

  /// randomize.
  final bool randomize;

  /// seed.
  final int? seed;

  /// allowed steps.
  final List<FaceActionType> allowedSteps;

  /// max steps.
  final int maxSteps;
}

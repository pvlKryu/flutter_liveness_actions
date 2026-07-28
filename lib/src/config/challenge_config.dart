import '../models/face_action_type.dart';

/// Configuration for guided face-action challenge sequences.
class FaceChallengeConfig {
  /// Creates challenge flow configuration.
  const FaceChallengeConfig({
    this.stepTimeout = const Duration(seconds: 8),
    this.maxRetriesPerStep = 2,
    this.randomize = false,
    this.seed,
    this.sequenceIdPrefix = 'sequence',
    this.requireCenterFaceFirst = true,
    this.allowDuplicateSteps = false,
    this.allowedSteps = const <FaceActionType>[
      FaceActionType.centerFace,
      FaceActionType.blinkOnce,
      FaceActionType.turnHeadLeft,
      FaceActionType.turnHeadRight,
      FaceActionType.holdStill,
    ],
    this.maxSteps = 5,
    this.enableTargetPath = false,
    this.randomizeTargetPath = false,
    this.targetSeed,
    this.maxTargetSteps = 5,
    this.useLowEndFriendlyTargets = false,
  });

  /// Timeout for each challenge step.
  final Duration stepTimeout;

  /// Maximum automatic retries before failing a step.
  final int maxRetriesPerStep;

  /// Whether to randomize step order (demo interaction pattern support only).
  final bool randomize;

  /// Optional deterministic seed for randomized sequences.
  final int? seed;

  /// Prefix used when generating [FaceChallengeSequence.sequenceId].
  final String sequenceIdPrefix;

  /// When randomizing, always place [FaceActionType.centerFace] first.
  final bool requireCenterFaceFirst;

  /// Whether the same action type may appear more than once.
  final bool allowDuplicateSteps;

  /// Allowed step types for sequence generation.
  final List<FaceActionType> allowedSteps;

  /// Maximum number of steps in a generated sequence.
  final int maxSteps;

  /// When true, randomized sequences may include a follow-target path step.
  final bool enableTargetPath;

  /// Randomize target zone order when generating target paths.
  final bool randomizeTargetPath;

  /// Optional seed for deterministic target path randomization.
  final int? targetSeed;

  /// Maximum zones in a generated target path.
  final int maxTargetSteps;

  /// Prefer larger / shorter target paths for lower-end devices.
  final bool useLowEndFriendlyTargets;

  /// Returns a copy with selectively overridden fields.
  FaceChallengeConfig copyWith({
    Duration? stepTimeout,
    int? maxRetriesPerStep,
    bool? randomize,
    int? seed,
    String? sequenceIdPrefix,
    bool? requireCenterFaceFirst,
    bool? allowDuplicateSteps,
    List<FaceActionType>? allowedSteps,
    int? maxSteps,
    bool? enableTargetPath,
    bool? randomizeTargetPath,
    int? targetSeed,
    int? maxTargetSteps,
    bool? useLowEndFriendlyTargets,
  }) {
    return FaceChallengeConfig(
      stepTimeout: stepTimeout ?? this.stepTimeout,
      maxRetriesPerStep: maxRetriesPerStep ?? this.maxRetriesPerStep,
      randomize: randomize ?? this.randomize,
      seed: seed ?? this.seed,
      sequenceIdPrefix: sequenceIdPrefix ?? this.sequenceIdPrefix,
      requireCenterFaceFirst:
          requireCenterFaceFirst ?? this.requireCenterFaceFirst,
      allowDuplicateSteps: allowDuplicateSteps ?? this.allowDuplicateSteps,
      allowedSteps: allowedSteps ?? this.allowedSteps,
      maxSteps: maxSteps ?? this.maxSteps,
      enableTargetPath: enableTargetPath ?? this.enableTargetPath,
      randomizeTargetPath: randomizeTargetPath ?? this.randomizeTargetPath,
      targetSeed: targetSeed ?? this.targetSeed,
      maxTargetSteps: maxTargetSteps ?? this.maxTargetSteps,
      useLowEndFriendlyTargets:
          useLowEndFriendlyTargets ?? this.useLowEndFriendlyTargets,
    );
  }
}

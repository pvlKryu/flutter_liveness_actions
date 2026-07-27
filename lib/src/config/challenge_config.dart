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
    );
  }
}

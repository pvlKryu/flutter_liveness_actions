import 'package:equatable/equatable.dart';

import 'challenge_step.dart';

/// face challenge sequence.
class FaceChallengeSequence extends Equatable {
  /// Creates an instance with optional overrides.
  const FaceChallengeSequence({
    required this.sequenceId,
    required this.steps,
    this.challengeNonce,
    this.seed,
  });

  /// sequence id.
  final String sequenceId;

  /// challenge nonce.
  final String? challengeNonce;

  /// seed.
  final int? seed;

  /// steps.
  final List<FaceChallengeStep> steps;

  @override

  /// props.
  List<Object?> get props => [sequenceId, challengeNonce, seed, steps];
}

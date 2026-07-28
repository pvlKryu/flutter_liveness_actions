import 'package:equatable/equatable.dart';

import '../models/challenge_failure_reason.dart';
import 'target_zone.dart';

/// Snapshot of a multi-zone face-center target path challenge.
///
/// Evaluates face bounding-box center movement — not eye tracking.
class TargetPathChallenge extends Equatable {
  /// Creates a target path challenge snapshot.
  const TargetPathChallenge({
    required this.sequenceId,
    required this.targets,
    required this.currentIndex,
    required this.completed,
    required this.failed,
    required this.progress,
    this.challengeNonce,
    this.failureReason = ChallengeFailureReason.none,
    this.failedTargetId,
    this.completedTargets = 0,
  });

  /// Sequence identifier for audit events.
  final String sequenceId;

  /// Ordered target zones.
  final List<TargetZone> targets;

  /// Index of the active target (`targets.length` when completed).
  final int currentIndex;

  /// Whether all targets were completed.
  final bool completed;

  /// Whether the path failed.
  final bool failed;

  /// Progress in `[0, 1]`.
  final double progress;

  /// Optional demo nonce for randomized paths.
  final String? challengeNonce;

  /// Failure reason when [failed] is true.
  final ChallengeFailureReason failureReason;

  /// Target id that caused failure, if any.
  final String? failedTargetId;

  /// Number of completed targets so far.
  final int completedTargets;

  /// Active target, if any.
  TargetZone? get currentTarget =>
      currentIndex >= 0 && currentIndex < targets.length
          ? targets[currentIndex]
          : null;

  /// Creates the initial state for [targets].
  factory TargetPathChallenge.initial({
    required String sequenceId,
    required List<TargetZone> targets,
    String? challengeNonce,
  }) {
    return TargetPathChallenge(
      sequenceId: sequenceId,
      targets: List<TargetZone>.unmodifiable(targets),
      currentIndex: 0,
      completed: targets.isEmpty,
      failed: false,
      progress: targets.isEmpty ? 1 : 0,
      challengeNonce: challengeNonce,
      completedTargets: 0,
    );
  }

  /// Privacy-safe audit metadata for this path.
  Map<String, Object?> auditMetadata() => <String, Object?>{
        'targetPathId': sequenceId,
        'targetCount': targets.length,
        'completedTargets': completedTargets,
        'failedTargetId': failedTargetId,
        'currentIndex': currentIndex,
        'completed': completed,
        'failed': failed,
        'failureReason': failureReason.name,
        if (challengeNonce != null) 'challengeNonce': challengeNonce,
      };

  /// Returns a copy with selectively overridden fields.
  TargetPathChallenge copyWith({
    String? sequenceId,
    List<TargetZone>? targets,
    int? currentIndex,
    bool? completed,
    bool? failed,
    double? progress,
    String? challengeNonce,
    ChallengeFailureReason? failureReason,
    String? failedTargetId,
    int? completedTargets,
  }) {
    return TargetPathChallenge(
      sequenceId: sequenceId ?? this.sequenceId,
      targets: targets ?? this.targets,
      currentIndex: currentIndex ?? this.currentIndex,
      completed: completed ?? this.completed,
      failed: failed ?? this.failed,
      progress: progress ?? this.progress,
      challengeNonce: challengeNonce ?? this.challengeNonce,
      failureReason: failureReason ?? this.failureReason,
      failedTargetId: failedTargetId ?? this.failedTargetId,
      completedTargets: completedTargets ?? this.completedTargets,
    );
  }

  @override
  List<Object?> get props => [
        sequenceId,
        targets,
        currentIndex,
        completed,
        failed,
        progress,
        challengeNonce,
        failureReason,
        failedTargetId,
        completedTargets,
      ];
}

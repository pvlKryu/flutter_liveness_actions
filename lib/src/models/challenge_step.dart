import 'package:equatable/equatable.dart';

import '../target/target_zone.dart';
import 'challenge_failure_reason.dart';
import 'face_action_type.dart';

/// Challenge step lifecycle status.
enum ChallengeStepStatus {
  /// Step has not started yet.
  pending,

  /// Step is actively being evaluated.
  inProgress,

  /// Step requirements were satisfied.
  passed,

  /// Step failed or timed out.
  failed,
}

/// Type alias for challenge step action types.
typedef ChallengeStepType = FaceActionType;

/// A single step in a guided face-action challenge sequence.
class FaceChallengeStep extends Equatable {
  /// Creates a challenge step.
  const FaceChallengeStep({
    required this.id,
    required this.type,
    required this.instruction,
    required this.status,
    this.startedAt,
    this.completedAt,
    this.timeout = const Duration(seconds: 8),
    this.retryCount = 0,
    this.failureReason = ChallengeFailureReason.none,
    this.targetZones,
  });

  /// Step identifier.
  final String id;

  /// Action type to evaluate.
  final ChallengeStepType type;

  /// Default English instruction text.
  final String instruction;

  /// Current status.
  final ChallengeStepStatus status;

  /// When the step became in-progress.
  final DateTime? startedAt;

  /// When the step finished.
  final DateTime? completedAt;

  /// Per-step timeout.
  final Duration timeout;

  /// Automatic retry count.
  final int retryCount;

  /// Failure reason when failed.
  final ChallengeFailureReason failureReason;

  /// Optional face-center target zones for [FaceActionType.followTargetPath].
  final List<TargetZone>? targetZones;

  /// Returns a copy with selectively overridden fields.
  FaceChallengeStep copyWith({
    String? id,
    ChallengeStepType? type,
    String? instruction,
    ChallengeStepStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    Duration? timeout,
    int? retryCount,
    ChallengeFailureReason? failureReason,
    List<TargetZone>? targetZones,
  }) {
    return FaceChallengeStep(
      id: id ?? this.id,
      type: type ?? this.type,
      instruction: instruction ?? this.instruction,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      timeout: timeout ?? this.timeout,
      retryCount: retryCount ?? this.retryCount,
      failureReason: failureReason ?? this.failureReason,
      targetZones: targetZones ?? this.targetZones,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        instruction,
        status,
        startedAt,
        completedAt,
        timeout,
        retryCount,
        failureReason,
        targetZones,
      ];
}

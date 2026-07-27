import 'package:equatable/equatable.dart';

import 'challenge_failure_reason.dart';
import 'face_action_type.dart';

/// challenge step status.
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

/// Type alias for ChallengeStepType.
typedef ChallengeStepType = FaceActionType;

/// face challenge step.
class FaceChallengeStep extends Equatable {
  /// Creates an instance with optional overrides.
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
  });

  /// id.
  final String id;

  /// type.
  final ChallengeStepType type;

  /// instruction.
  final String instruction;

  /// status.
  final ChallengeStepStatus status;

  /// started at.
  final DateTime? startedAt;

  /// completed at.
  final DateTime? completedAt;

  /// timeout.
  final Duration timeout;

  /// retry count.
  final int retryCount;

  /// failure reason.
  final ChallengeFailureReason failureReason;

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
      ];
}

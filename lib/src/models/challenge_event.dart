import 'package:equatable/equatable.dart';

import 'challenge_failure_reason.dart';

/// face challenge event type.
enum FaceChallengeEventType {
  /// challenge started.
  challengeStarted,

  /// step passed.
  stepPassed,

  /// step failed.
  stepFailed,

  /// retry requested.
  retryRequested,

  /// challenge completed.
  challengeCompleted,

  /// challenge failed.
  challengeFailed,
}

/// face challenge event.
class FaceChallengeEvent extends Equatable {
  /// Creates an instance with optional overrides.
  const FaceChallengeEvent({
    required this.type,
    required this.timestamp,
    this.stepId,
    this.message,
    this.failureReason = ChallengeFailureReason.none,
  });

  /// type.
  final FaceChallengeEventType type;

  /// timestamp.
  final DateTime timestamp;

  /// step id.
  final String? stepId;

  /// message.
  final String? message;

  /// failure reason.
  final ChallengeFailureReason failureReason;

  @override

  /// props.
  List<Object?> get props => [type, timestamp, stepId, message, failureReason];
}

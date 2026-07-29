import 'package:equatable/equatable.dart';

import '../security/security_violation_code.dart';
import 'challenge_failure_reason.dart';
import 'challenge_step.dart';

/// face challenge state.
class FaceChallengeState extends Equatable {
  /// Creates an instance with optional overrides.
  const FaceChallengeState({
    required this.steps,
    required this.currentStepIndex,
    required this.completed,
    required this.failed,
    required this.progress,
    this.failureReason = ChallengeFailureReason.none,
    this.compromised = false,
    this.securityViolation,
  });

  /// steps.
  final List<FaceChallengeStep> steps;

  /// current step index.
  final int currentStepIndex;

  /// completed.
  final bool completed;

  /// failed.
  final bool failed;

  /// progress.
  final double progress;

  /// failure reason.
  final ChallengeFailureReason failureReason;

  /// Whether the challenge is locked by a security fail-safe.
  ///
  /// Compromised sessions cannot advance via [ChallengeFlowController]
  /// until [ChallengeFlowController.reset] is called.
  final bool compromised;

  /// Security violation that caused [compromised], if any.
  final SecurityViolationCode? securityViolation;

  /// Whether the challenge is terminal (completed, failed, or compromised).
  bool get isTerminal => completed || failed || compromised;

  /// current step.
  FaceChallengeStep? get currentStep =>
      currentStepIndex >= 0 && currentStepIndex < steps.length
          ? steps[currentStepIndex]
          : null;

  /// Creates the initial state for a new challenge [steps] list.
  factory FaceChallengeState.initial(List<FaceChallengeStep> steps) {
    return FaceChallengeState(
      steps: steps,
      currentStepIndex: 0,
      completed: false,
      failed: false,
      progress: 0,
    );
  }

  @override
  List<Object?> get props => [
        steps,
        currentStepIndex,
        completed,
        failed,
        progress,
        failureReason,
        compromised,
        securityViolation,
      ];
}

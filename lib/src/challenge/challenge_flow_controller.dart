import 'dart:async';

import '../config/challenge_config.dart';
import '../models/challenge_event.dart';
import '../models/challenge_failure_reason.dart';
import '../models/challenge_sequence.dart';
import '../models/challenge_state.dart';
import '../models/challenge_step.dart';
import '../models/face_action_signal.dart';
import 'challenge_sequence_factory.dart';
import 'challenge_step_evaluator.dart';

/// Coordinates guided face-action challenge sequences from derived signals.
class ChallengeFlowController {
  /// Creates a controller with optional challenge [config].
  ChallengeFlowController({
    FaceChallengeConfig config = const FaceChallengeConfig(),
    ChallengeSequenceFactory? sequenceFactory,
    ChallengeStepEvaluator? stepEvaluator,
  })  : _config = config,
        _sequenceFactory = sequenceFactory ?? const ChallengeSequenceFactory(),
        _stepEvaluator = stepEvaluator ?? const ChallengeStepEvaluator() {
    reset();
  }

  final FaceChallengeConfig _config;
  final ChallengeSequenceFactory _sequenceFactory;
  final ChallengeStepEvaluator _stepEvaluator;
  final StreamController<FaceChallengeEvent> _events =
      StreamController<FaceChallengeEvent>.broadcast();

  late FaceChallengeSequence _sequence;
  late FaceChallengeState _state;

  /// Broadcast stream of challenge lifecycle events.
  Stream<FaceChallengeEvent> get events => _events.stream;

  /// Current challenge progress state.
  FaceChallengeState get state => _state;

  /// Active challenge sequence for this controller instance.
  FaceChallengeSequence get sequence => _sequence;

  /// Rebuilds a new sequence and emits [FaceChallengeEventType.challengeStarted].
  void reset() {
    _sequence = _sequenceFactory.create(_config);
    _state = FaceChallengeState.initial(_sequence.steps);
    _events.add(FaceChallengeEvent(
      type: FaceChallengeEventType.challengeStarted,
      timestamp: DateTime.now(),
    ));
  }

  /// Advances the challenge using a derived [signal].
  void processSignal(FaceActionSignal signal, {DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    if (_state.completed || _state.failed || _state.currentStep == null) {
      return;
    }

    final current = _state.currentStep!;
    if (current.status == ChallengeStepStatus.pending) {
      _replaceCurrent(current.copyWith(
        status: ChallengeStepStatus.inProgress,
        startedAt: timestamp,
      ));
    }

    final active = _state.currentStep!;
    final started = active.startedAt ?? timestamp;

    if (timestamp.difference(started) > active.timeout) {
      _failCurrent(ChallengeFailureReason.timeout, timestamp);
      return;
    }

    if (_stepEvaluator.evaluate(active, signal)) {
      _passCurrent(timestamp);
    }
  }

  /// Retries the current step and increments its retry counter.
  void retryCurrentStep({DateTime? now}) {
    final current = _state.currentStep;
    if (current == null) {
      return;
    }
    final timestamp = now ?? DateTime.now();
    final updated = current.copyWith(
      status: ChallengeStepStatus.inProgress,
      retryCount: current.retryCount + 1,
      startedAt: timestamp,
      failureReason: ChallengeFailureReason.none,
    );
    _replaceCurrent(updated);
    _events.add(FaceChallengeEvent(
      type: FaceChallengeEventType.retryRequested,
      timestamp: timestamp,
      stepId: updated.id,
    ));
  }

  void _passCurrent(DateTime timestamp) {
    final current = _state.currentStep!;
    _replaceCurrent(current.copyWith(
      status: ChallengeStepStatus.passed,
      completedAt: timestamp,
      startedAt: current.startedAt ?? timestamp,
    ));
    _events.add(FaceChallengeEvent(
      type: FaceChallengeEventType.stepPassed,
      timestamp: timestamp,
      stepId: current.id,
    ));

    final nextIndex = _state.currentStepIndex + 1;
    final done = nextIndex >= _state.steps.length;
    _state = FaceChallengeState(
      steps: _state.steps,
      currentStepIndex: done ? _state.currentStepIndex : nextIndex,
      completed: done,
      failed: false,
      progress: _state.steps
              .where((s) => s.status == ChallengeStepStatus.passed)
              .length /
          _state.steps.length,
    );
    if (done) {
      _events.add(FaceChallengeEvent(
        type: FaceChallengeEventType.challengeCompleted,
        timestamp: timestamp,
      ));
    }
  }

  void _failCurrent(ChallengeFailureReason reason, DateTime timestamp) {
    final current = _state.currentStep!;
    if (current.retryCount < _config.maxRetriesPerStep) {
      retryCurrentStep(now: timestamp);
      return;
    }
    _replaceCurrent(current.copyWith(
      status: ChallengeStepStatus.failed,
      failureReason: reason,
      completedAt: timestamp,
    ));
    _state = FaceChallengeState(
      steps: _state.steps,
      currentStepIndex: _state.currentStepIndex,
      completed: false,
      failed: true,
      progress: _state.progress,
      failureReason: reason,
    );
    _events.add(FaceChallengeEvent(
      type: FaceChallengeEventType.challengeFailed,
      timestamp: timestamp,
      stepId: current.id,
      failureReason: reason,
    ));
  }

  void _replaceCurrent(FaceChallengeStep step) {
    final updated = List<FaceChallengeStep>.from(_state.steps);
    updated[_state.currentStepIndex] = step;
    _state = FaceChallengeState(
      steps: updated,
      currentStepIndex: _state.currentStepIndex,
      completed: _state.completed,
      failed: _state.failed,
      progress:
          updated.where((s) => s.status == ChallengeStepStatus.passed).length /
              updated.length,
      failureReason: _state.failureReason,
    );
  }

  /// Closes the event stream.
  void dispose() {
    _events.close();
  }
}

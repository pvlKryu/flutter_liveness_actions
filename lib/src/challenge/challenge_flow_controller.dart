import 'dart:async';

import '../config/challenge_config.dart';
import '../models/challenge_event.dart';
import '../models/challenge_failure_reason.dart';
import '../models/challenge_sequence.dart';
import '../models/challenge_state.dart';
import '../models/challenge_step.dart';
import '../models/face_action_frame.dart';
import '../models/face_action_signal.dart';
import '../models/face_action_type.dart';
import '../target/target_path_evaluator.dart';
import '../target/target_zone.dart';
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
  TargetPathEvaluator? _targetEvaluator;

  /// Broadcast stream of challenge lifecycle events.
  Stream<FaceChallengeEvent> get events => _events.stream;

  /// Current challenge progress state.
  FaceChallengeState get state => _state;

  /// Active challenge sequence for this controller instance.
  FaceChallengeSequence get sequence => _sequence;

  /// Active target-path evaluator when the current step uses target zones.
  TargetPathEvaluator? get targetEvaluator => _targetEvaluator;

  /// Rebuilds a new sequence and emits [FaceChallengeEventType.challengeStarted].
  void reset() {
    _sequence = _sequenceFactory.create(_config);
    _state = FaceChallengeState.initial(_sequence.steps);
    _targetEvaluator = null;
    _events.add(FaceChallengeEvent(
      type: FaceChallengeEventType.challengeStarted,
      timestamp: DateTime.now(),
    ));
  }

  /// Advances the challenge using a derived [signal].
  ///
  /// For [FaceActionType.followTargetPath] steps, prefer [processFrame].
  void processSignal(FaceActionSignal signal, {DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    if (_state.completed || _state.failed || _state.currentStep == null) {
      return;
    }

    final current = _ensureInProgress(timestamp);
    if (_isTargetPathStep(current)) {
      return;
    }

    if (timestamp.difference(current.startedAt ?? timestamp) >
        current.timeout) {
      _failCurrent(ChallengeFailureReason.timeout, timestamp);
      return;
    }

    if (_stepEvaluator.evaluate(current, signal)) {
      _passCurrent(timestamp);
    }
  }

  /// Advances geometry-based steps (target path / move-to-zone) using [frame].
  void processFrame(FaceActionFrame frame, {DateTime? now}) {
    final timestamp = now ?? frame.timestamp;
    if (_state.completed || _state.failed || _state.currentStep == null) {
      return;
    }

    final current = _ensureInProgress(timestamp);

    if (_isTargetPathStep(current)) {
      _ensureTargetEvaluator(current);
      final result = _targetEvaluator!.processFrame(frame);
      if (result.pathCompleted ||
          (_targetEvaluator!.state.completed && result.completed)) {
        _passCurrent(timestamp);
        return;
      }
      if (result.pathFailed || _targetEvaluator!.state.failed) {
        _failCurrent(
          _targetEvaluator!.state.failureReason,
          timestamp,
        );
        return;
      }
      return;
    }

    if (timestamp.difference(current.startedAt ?? timestamp) >
        current.timeout) {
      _failCurrent(ChallengeFailureReason.timeout, timestamp);
      return;
    }

    if (_stepEvaluator.evaluateFrame(current, frame)) {
      // Instant zone entry for moveTo* / followTarget single-zone steps.
      // Require a tiny hold via successive frames by checking startedAt age
      // is unnecessary for demos — hosts may use TargetPathEvaluator for hold.
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
    _targetEvaluator = null;
    _events.add(FaceChallengeEvent(
      type: FaceChallengeEventType.retryRequested,
      timestamp: timestamp,
      stepId: updated.id,
    ));
  }

  FaceChallengeStep _ensureInProgress(DateTime timestamp) {
    final current = _state.currentStep!;
    if (current.status == ChallengeStepStatus.pending) {
      _replaceCurrent(current.copyWith(
        status: ChallengeStepStatus.inProgress,
        startedAt: timestamp,
      ));
    }
    return _state.currentStep!;
  }

  bool _isTargetPathStep(FaceChallengeStep step) {
    return step.type == FaceActionType.followTargetPath &&
        step.targetZones != null &&
        step.targetZones!.isNotEmpty;
  }

  void _ensureTargetEvaluator(FaceChallengeStep step) {
    if (_targetEvaluator != null) {
      return;
    }
    final zones = List<TargetZone>.from(step.targetZones!);
    _targetEvaluator = TargetPathEvaluator(
      targets: zones,
      sequenceId: '${_sequence.sequenceId}-${step.id}',
      challengeNonce: _sequence.challengeNonce,
    );
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
    _targetEvaluator = null;

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
    _targetEvaluator = null;
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

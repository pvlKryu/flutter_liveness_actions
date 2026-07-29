import '../config/face_action_config.dart';
import '../smoothing/hysteresis_threshold.dart';
import '../smoothing/signal_smoother.dart';

enum _BlinkPhase { waitingOpen, waitingClosed, waitingReopen }

/// Detects open → closed → reopen blink sequences from eye probabilities.
class BlinkDetector {
  /// Creates a blink detector with optional [config] and [smoother].
  BlinkDetector({
    FaceActionConfig config = const FaceActionConfig(),
    SignalSmoother? smoother,
  })  : _config = config,
        _smoother = smoother ?? SignalSmoother(bufferSize: 2),
        _eyeOpenHysteresis = HysteresisThreshold(
          onThreshold: config.eyeOpenThreshold,
          offThreshold: config.eyeClosedThreshold,
          initialState: false,
        );

  final FaceActionConfig _config;
  final SignalSmoother _smoother;
  final HysteresisThreshold _eyeOpenHysteresis;

  _BlinkPhase _phase = _BlinkPhase.waitingOpen;
  DateTime? _sequenceStartedAt;
  DateTime? _latchedUntil;
  int _closedFrames = 0;
  int _openFramesAfter = 0;

  /// How long a completed blink stays asserted for challenge consumers.
  static const Duration latchDuration = Duration(milliseconds: 450);

  /// Updates blink state and returns true while a blink is latched / just completed.
  bool update({
    required double? leftEyeOpenProbability,
    required double? rightEyeOpenProbability,
    required DateTime timestamp,
  }) {
    if (_latchedUntil != null) {
      if (timestamp.isBefore(_latchedUntil!)) {
        return true;
      }
      _latchedUntil = null;
    }

    if (leftEyeOpenProbability == null || rightEyeOpenProbability == null) {
      return false;
    }

    final avgEyeOpen = _smoother
        .smoothEye((leftEyeOpenProbability + rightEyeOpenProbability) / 2);
    final eyesOpen = _eyeOpenHysteresis.apply(avgEyeOpen);

    if (_sequenceStartedAt != null &&
        timestamp.difference(_sequenceStartedAt!) > _config.maxBlinkDuration) {
      _resetSequence();
      return false;
    }

    if (_phase == _BlinkPhase.waitingOpen) {
      if (eyesOpen) {
        _phase = _BlinkPhase.waitingClosed;
        _sequenceStartedAt = timestamp;
      }
      return false;
    }

    if (_phase == _BlinkPhase.waitingClosed) {
      if (!eyesOpen) {
        _closedFrames += 1;
        if (_closedFrames >= _config.minClosedFrames) {
          _phase = _BlinkPhase.waitingReopen;
        }
      }
      return false;
    }

    // waitingReopen
    if (eyesOpen) {
      _openFramesAfter += 1;
      if (_openFramesAfter >= _config.minOpenFramesAfter) {
        _resetSequence();
        _latchedUntil = timestamp.add(latchDuration);
        return true;
      }
    }
    return false;
  }

  void _resetSequence() {
    _phase = _BlinkPhase.waitingOpen;
    _closedFrames = 0;
    _openFramesAfter = 0;
    _sequenceStartedAt = null;
    _eyeOpenHysteresis.reset();
  }

  /// Clears sequence state and any active latch.
  void reset() {
    _resetSequence();
    _latchedUntil = null;
  }
}

import '../config/face_action_config.dart';
import '../smoothing/hysteresis_threshold.dart';
import '../smoothing/signal_smoother.dart';

enum _BlinkPhase { waitingOpen, waitingClosed, waitingReopen }

/// blink detector.
class BlinkDetector {
  /// Creates a blink detector with optional [config] and [smoother].
  BlinkDetector({
    FaceActionConfig config = const FaceActionConfig(),
    SignalSmoother? smoother,
  })  : _config = config,
        _smoother = smoother ?? SignalSmoother(),
        _eyeOpenHysteresis = HysteresisThreshold(
          onThreshold: config.eyeOpenThreshold,
          offThreshold: config.eyeClosedThreshold,
          initialState: false,
        );

  ///  config.
  final FaceActionConfig _config;

  ///  smoother.
  final SignalSmoother _smoother;

  ///  eye open hysteresis.
  final HysteresisThreshold _eyeOpenHysteresis;

  _BlinkPhase _phase = _BlinkPhase.waitingOpen;
  DateTime? _sequenceStartedAt;
  int _closedFrames = 0;
  int _openFramesAfter = 0;

  /// Updates blink state from eye probabilities and returns true when a blink completes.
  bool update({
    required double? leftEyeOpenProbability,
    required double? rightEyeOpenProbability,
    required DateTime timestamp,
  }) {
    if (leftEyeOpenProbability == null || rightEyeOpenProbability == null) {
      return false;
    }

    final avgEyeOpen = _smoother
        .smoothEye((leftEyeOpenProbability + rightEyeOpenProbability) / 2);
    final eyesOpen = _eyeOpenHysteresis.apply(avgEyeOpen);

    if (_sequenceStartedAt != null &&
        timestamp.difference(_sequenceStartedAt!) > _config.maxBlinkDuration) {
      reset();
      return false;
    }

    switch (_phase) {
      case _BlinkPhase.waitingOpen:
        if (eyesOpen) {
          _phase = _BlinkPhase.waitingClosed;
          _sequenceStartedAt = timestamp;
        }
      case _BlinkPhase.waitingClosed:
        if (!eyesOpen) {
          _closedFrames += 1;
          if (_closedFrames >= _config.minClosedFrames) {
            _phase = _BlinkPhase.waitingReopen;
          }
        }
      case _BlinkPhase.waitingReopen:
        if (eyesOpen) {
          _openFramesAfter += 1;
          if (_openFramesAfter >= _config.minOpenFramesAfter) {
            reset();
            return true;
          }
        }
    }
    return false;
  }

  /// reset.
  void reset() {
    _phase = _BlinkPhase.waitingOpen;
    _closedFrames = 0;
    _openFramesAfter = 0;
    _sequenceStartedAt = null;
    _eyeOpenHysteresis.reset();
  }
}

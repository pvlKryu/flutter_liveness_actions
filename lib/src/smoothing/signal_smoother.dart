import 'hysteresis_threshold.dart';
import 'temporal_signal_buffer.dart';

/// signal smoother.
class SignalSmoother {
  /// Creates a smoother with configurable [bufferSize] and stability requirements.
  SignalSmoother({
    this.bufferSize = 5,
    this.requiredConsecutiveFrames = 2,
  })  : _eyeBuffer = TemporalSignalBuffer(maxSize: bufferSize),
        _yawBuffer = TemporalSignalBuffer(maxSize: bufferSize),
        _rollBuffer = TemporalSignalBuffer(maxSize: bufferSize);

  /// buffer size.
  final int bufferSize;

  /// required consecutive frames.
  final int requiredConsecutiveFrames;

  ///  eye buffer.
  final TemporalSignalBuffer _eyeBuffer;

  ///  yaw buffer.
  final TemporalSignalBuffer _yawBuffer;

  ///  roll buffer.
  final TemporalSignalBuffer _rollBuffer;

  int _trueStreak = 0;

  /// smooth eye.
  double smoothEye(double value) {
    _eyeBuffer.add(value);
    return _eyeBuffer.average;
  }

  /// smooth yaw.
  double smoothYaw(double value) {
    _yawBuffer.add(value);
    return _yawBuffer.average;
  }

  /// smooth roll.
  double smoothRoll(double value) {
    _rollBuffer.add(value);
    return _rollBuffer.average;
  }

  /// stable boolean.
  bool stableBoolean(bool value) {
    if (value) {
      _trueStreak += 1;
      return _trueStreak >= requiredConsecutiveFrames;
    }
    _trueStreak = 0;
    return false;
  }

  /// Applies [threshold] hysteresis and requires consecutive stable frames.
  bool stableHysteresis({
    required double value,
    required HysteresisThreshold threshold,
  }) {
    return stableBoolean(threshold.apply(value));
  }

  /// Clears all internal buffers and stability counters.
  void reset() {
    _trueStreak = 0;
    _eyeBuffer.clear();
    _yawBuffer.clear();
    _rollBuffer.clear();
  }
}

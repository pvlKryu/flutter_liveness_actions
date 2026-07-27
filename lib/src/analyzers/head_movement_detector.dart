import '../config/face_action_config.dart';
import '../smoothing/signal_smoother.dart';

/// head movement detector.
class HeadMovementDetector {
  /// Creates a head movement detector with optional [config] and [smoother].
  HeadMovementDetector({
    FaceActionConfig config = const FaceActionConfig(),
    SignalSmoother? smoother,
  })  : _config = config,
        _smoother = smoother ?? SignalSmoother();

  ///  config.
  final FaceActionConfig _config;

  ///  smoother.
  final SignalSmoother _smoother;

  int _leftFrames = 0;
  int _rightFrames = 0;
  int _tiltFrames = 0;

  /// Detects left, right, and tilt head movement from smoothed yaw/roll.
  ({bool left, bool right, bool tilted}) detect({
    required double? yaw,
    required double? roll,
  }) {
    final smoothYaw = _smoother.smoothYaw(yaw ?? 0);
    final smoothRoll = _smoother.smoothRoll(roll ?? 0);

    _leftFrames = smoothYaw <= _config.yawLeftThreshold ? _leftFrames + 1 : 0;
    _rightFrames =
        smoothYaw >= _config.yawRightThreshold ? _rightFrames + 1 : 0;
    _tiltFrames =
        smoothRoll.abs() >= _config.rollThreshold ? _tiltFrames + 1 : 0;

    return (
      left: _leftFrames >= _config.minFramesForMovement,
      right: _rightFrames >= _config.minFramesForMovement,
      tilted: _tiltFrames >= _config.minFramesForMovement,
    );
  }
}

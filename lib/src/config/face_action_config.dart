/// face action config.
class FaceActionConfig {
  /// Creates an instance with optional overrides.
  const FaceActionConfig({
    this.eyeOpenThreshold = 0.65,
    this.eyeClosedThreshold = 0.30,
    this.maxBlinkDuration = const Duration(milliseconds: 1200),
    this.minClosedFrames = 1,
    this.minOpenFramesAfter = 1,
    this.yawLeftThreshold = -18,
    this.yawRightThreshold = 18,
    this.rollThreshold = 15,
    this.minFramesForMovement = 2,
    this.centerTolerance = 0.18,
    this.minFaceAreaRatio = 0.08,
    this.maxFaceAreaRatio = 0.45,
    this.requiredStableFrames = 3,
  });

  /// eye open threshold.
  final double eyeOpenThreshold;

  /// eye closed threshold.
  final double eyeClosedThreshold;

  /// max blink duration.
  final Duration maxBlinkDuration;

  /// min closed frames.
  final int minClosedFrames;

  /// min open frames after.
  final int minOpenFramesAfter;

  /// yaw left threshold.
  final double yawLeftThreshold;

  /// yaw right threshold.
  final double yawRightThreshold;

  /// roll threshold.
  final double rollThreshold;

  /// min frames for movement.
  final int minFramesForMovement;

  /// center tolerance.
  final double centerTolerance;

  /// min face area ratio.
  final double minFaceAreaRatio;

  /// max face area ratio.
  final double maxFaceAreaRatio;

  /// required stable frames.
  final int requiredStableFrames;
}

/// Configuration for derived face-action analyzers and target tracking.
class FaceActionConfig {
  /// Creates analyzer / target-tracking configuration.
  const FaceActionConfig({
    this.eyeOpenThreshold = 0.65,
    this.eyeClosedThreshold = 0.30,
    this.maxBlinkDuration = const Duration(milliseconds: 2000),
    this.minClosedFrames = 1,
    this.minOpenFramesAfter = 1,
    this.yawLeftThreshold = -18,
    this.yawRightThreshold = 18,
    this.rollThreshold = 15,
    this.pitchUpThreshold = -12,
    this.pitchDownThreshold = 12,
    this.minFramesForMovement = 2,
    this.centerTolerance = 0.18,
    this.minFaceAreaRatio = 0.08,
    this.maxFaceAreaRatio = 0.45,
    this.requiredStableFrames = 3,
    this.smileThreshold = 0.7,
    this.targetZoneDefaultRadius = 0.14,
    this.targetHoldDuration = const Duration(milliseconds: 450),
    this.targetTimeout = const Duration(seconds: 8),
    this.targetSmoothingFactor = 0.35,
    this.requiredTargetStableFrames = 2,
  });

  /// Eye-open probability threshold.
  final double eyeOpenThreshold;

  /// Eye-closed probability threshold.
  final double eyeClosedThreshold;

  /// Maximum blink duration window.
  final Duration maxBlinkDuration;

  /// Minimum closed frames for a blink.
  final int minClosedFrames;

  /// Minimum open frames after a blink.
  final int minOpenFramesAfter;

  /// Yaw threshold for left turn (degrees).
  final double yawLeftThreshold;

  /// Yaw threshold for right turn (degrees).
  final double yawRightThreshold;

  /// Roll threshold for tilt (degrees).
  final double rollThreshold;

  /// Optional pitch-up threshold when [FaceActionFrame.headEulerAngleX] is set.
  final double pitchUpThreshold;

  /// Optional pitch-down threshold when [FaceActionFrame.headEulerAngleX] is set.
  final double pitchDownThreshold;

  /// Minimum frames required to confirm head movement.
  final int minFramesForMovement;

  /// Center tolerance for face positioning.
  final double centerTolerance;

  /// Minimum face area ratio.
  final double minFaceAreaRatio;

  /// Maximum face area ratio.
  final double maxFaceAreaRatio;

  /// Required stable frames for hold-still.
  final int requiredStableFrames;

  /// Smile probability threshold.
  final double smileThreshold;

  /// Default normalized radius for target zones.
  final double targetZoneDefaultRadius;

  /// Default hold duration inside a target zone.
  final Duration targetHoldDuration;

  /// Default timeout per target zone.
  final Duration targetTimeout;

  /// Reserved smoothing factor for hosts (0–1). Core evaluator is allocation-light.
  final double targetSmoothingFactor;

  /// Consecutive inside-target frames required before hold completion.
  final int requiredTargetStableFrames;
}

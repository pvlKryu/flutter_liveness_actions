/// Supported face-action / challenge step types.
enum FaceActionType {
  /// Center the face in frame.
  centerFace,

  /// Blink once.
  blinkOnce,

  /// Turn head left (yaw).
  turnHeadLeft,

  /// Turn head right (yaw).
  turnHeadRight,

  /// Hold still.
  holdStill,

  /// Smile (uses smilingProbability).
  smile,

  /// Follow a single on-screen target (face-center tracking).
  followTarget,

  /// Follow a multi-zone target path (face-center tracking).
  followTargetPath,

  /// Move face center toward top-left.
  moveToTopLeft,

  /// Move face center toward top-right.
  moveToTopRight,

  /// Move face center toward bottom-left.
  moveToBottomLeft,

  /// Move face center toward bottom-right.
  moveToBottomRight,

  /// Move face center toward screen center.
  moveToCenter,
}

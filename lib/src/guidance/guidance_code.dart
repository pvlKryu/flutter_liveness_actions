/// Stable guidance codes for localization and UX metadata.
enum GuidanceCode {
  /// Move closer to the camera.
  moveCloser,

  /// Move farther from the camera.
  moveFarther,

  /// Center the face.
  centerFace,

  /// Improve lighting.
  improveLighting,

  /// Hold still.
  holdStill,

  /// Blink once.
  blinkOnce,

  /// Turn head left.
  turnHeadLeft,

  /// Turn head right.
  turnHeadRight,

  /// Only one person should be visible.
  onlyOnePerson,

  /// Camera permission required.
  cameraPermissionRequired,

  /// Challenge completed.
  challengeCompleted,

  /// Retry challenge.
  retryChallenge,

  /// Processing is slow.
  processingSlow,

  /// Face out of frame.
  faceOutOfFrame,

  /// No face detected.
  noFaceDetected,

  /// Smile.
  smile,

  /// Follow the on-screen target (face-center tracking).
  followTheDot,

  /// Move face toward the target.
  moveFaceToTarget,

  /// Hold inside the target zone.
  holdInsideTarget,

  /// Current target completed.
  targetCompleted,

  /// Target missed.
  targetMissed,

  /// Face lost during target challenge.
  faceLostDuringTargetChallenge,

  /// Target challenge timed out.
  targetChallengeTimeout,

  /// Nudge slightly left.
  moveSlightlyLeft,

  /// Nudge slightly right.
  moveSlightlyRight,

  /// Nudge slightly up.
  moveSlightlyUp,

  /// Nudge slightly down.
  moveSlightlyDown,
}

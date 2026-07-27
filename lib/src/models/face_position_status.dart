/// Derived face position classification for a single frame.
enum FacePositionStatus {
  /// Position could not be determined.
  unknown,

  /// No face detected.
  noFace,

  /// More than one face detected.
  multipleFaces,

  /// Face is centered within tolerance.
  centered,

  /// Face is in frame but not centered enough.
  notCentered,

  /// Face appears too close to the camera.
  tooClose,

  /// Face appears too far from the camera.
  tooFar,

  /// Face bounding box is outside the image frame.
  outOfFrame,
}

/// face quality warning.
enum FaceQualityWarning {
  /// no face.
  noFace,

  /// multiple faces.
  multipleFaces,

  /// not centered.
  notCentered,

  /// too close.
  tooClose,

  /// too far.
  tooFar,

  /// out of frame.
  outOfFrame,

  /// unstable position.
  unstablePosition,

  /// insufficient stable frames.
  insufficientStableFrames,

  /// low confidence heuristic.
  lowConfidenceHeuristic,

  /// low light heuristic.
  lowLightHeuristic,

  /// over exposed heuristic.
  overExposedHeuristic,
}

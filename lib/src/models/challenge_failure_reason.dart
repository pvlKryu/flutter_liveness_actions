/// challenge failure reason.
enum ChallengeFailureReason {
  /// none.
  none,

  /// timeout.
  timeout,

  /// quality gate rejected.
  qualityGateRejected,

  /// lost face.
  lostFace,

  /// user cancelled.
  userCancelled,

  /// unknown.
  unknown,
}

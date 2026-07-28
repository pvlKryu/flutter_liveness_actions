/// Reasons a challenge step or target path may fail.
enum ChallengeFailureReason {
  /// No failure.
  none,

  /// Step / target timed out.
  timeout,

  /// Quality gate rejected the frame.
  qualityGateRejected,

  /// Face was lost during the challenge.
  lostFace,

  /// More than one face was detected.
  multipleFaces,

  /// User cancelled the challenge.
  userCancelled,

  /// Target zone was missed (reserved for host-level policy).
  targetMissed,

  /// Unknown failure.
  unknown,
}

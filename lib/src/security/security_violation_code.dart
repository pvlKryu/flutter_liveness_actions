/// Stable codes for session-level security fail-safes.
///
/// These are derived-signal policy flags for onboarding demos — not identity,
/// KYC, or biometric authentication decisions.
enum SecurityViolationCode {
  /// More than one face was detected in a processed frame.
  ///
  /// Used as a fail-safe against shoulder-surfing / social-engineering
  /// scenarios where a second person enters the camera FOV.
  multiFaceDetected,
}

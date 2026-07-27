/// UX severity for guidance messages.
enum GuidanceSeverity {
  /// Informational guidance.
  info,

  /// Warning that may block challenge progress.
  warning,

  /// Error requiring user action.
  error,

  /// Positive completion feedback.
  success,
}

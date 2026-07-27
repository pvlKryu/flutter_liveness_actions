/// liveness action exception.
class LivenessActionException implements Exception {
  /// Creates an instance with optional overrides.
  const LivenessActionException(this.message, {this.cause});

  /// message.
  final String message;

  /// cause.
  final Object? cause;

  @override
  String toString() =>
      'LivenessActionException(message: $message, cause: $cause)';
}

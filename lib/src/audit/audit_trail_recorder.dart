/// Privacy-safe audit trail event types for demo onboarding flows.
enum AuditTrailEventType {
  /// Session started.
  sessionStarted,

  /// Camera became ready for analysis.
  cameraReady,

  /// Quality gate accepted a stable frame.
  qualityGatePassed,

  /// Challenge sequence started.
  challengeStarted,

  /// Challenge step passed.
  stepPassed,

  /// Challenge step failed.
  stepFailed,

  /// Retry requested for a step.
  retryRequested,

  /// Challenge sequence completed.
  challengeCompleted,

  /// Diagnostics summary captured.
  diagnosticsSummary,
}

/// Single audit-friendly timeline entry without personal data.
class AuditTrailEntry {
  /// Creates an audit trail entry.
  const AuditTrailEntry({
    required this.type,
    required this.timestamp,
    this.stepId,
    this.stepType,
    this.message,
    this.metadata = const <String, Object?>{},
  });

  /// Event classification.
  final AuditTrailEventType type;

  /// UTC-safe timestamp recorded by the app/session.
  final DateTime timestamp;

  /// Optional challenge step id.
  final String? stepId;

  /// Optional challenge step type name.
  final String? stepType;

  /// Optional short human-readable note (non-PII).
  final String? message;

  /// Additional privacy-safe metadata.
  final Map<String, Object?> metadata;

  /// Serializes this entry to a JSON-compatible map.
  Map<String, Object?> toJson() => <String, Object?>{
        'type': type.name,
        'timestamp': timestamp.toUtc().toIso8601String(),
        'stepId': stepId,
        'stepType': stepType,
        'message': message,
        'metadata': metadata,
      };
}

/// Records privacy-safe audit trail entries during a demo session.
class AuditTrailRecorder {
  /// Creates an empty audit trail recorder.
  AuditTrailRecorder();

  final List<AuditTrailEntry> _entries = <AuditTrailEntry>[];

  /// Recorded entries in insertion order.
  List<AuditTrailEntry> get entries => List.unmodifiable(_entries);

  /// Records a new [type] event.
  void record(
    AuditTrailEventType type, {
    DateTime? timestamp,
    String? stepId,
    String? stepType,
    String? message,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    _entries.add(
      AuditTrailEntry(
        type: type,
        timestamp: timestamp ?? DateTime.now(),
        stepId: stepId,
        stepType: stepType,
        message: message,
        metadata: metadata,
      ),
    );
  }

  /// Serializes the trail for inclusion in audit JSON.
  List<Map<String, Object?>> toJsonList() =>
      _entries.map((e) => e.toJson()).toList(growable: false);

  /// Clears all recorded entries.
  void clear() => _entries.clear();
}

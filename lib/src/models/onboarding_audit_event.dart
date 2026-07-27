import 'package:equatable/equatable.dart';

/// Privacy-safe onboarding audit event for demo flows.
class OnboardingAuditEvent extends Equatable {
  /// Creates an onboarding audit event.
  const OnboardingAuditEvent({
    required this.sessionId,
    required this.sequenceId,
    required this.startedAt,
    required this.packageVersion,
    required this.faceDetected,
    required this.multipleFacesDetected,
    required this.steps,
    this.challengeNonce,
    this.completedAt,
    this.events = const <Map<String, Object?>>[],
    this.rawImagesStored = false,
    this.identityDecision = 'not_performed',
    this.creditDecision = 'not_performed',
    this.demoOnly = true,
    this.diagnostics = const <String, Object?>{},
    this.privacy = const <String, Object?>{},
  });

  /// Demo session identifier.
  final String sessionId;

  /// Challenge sequence identifier.
  final String sequenceId;

  /// Optional demo nonce for randomized sequences.
  final String? challengeNonce;

  /// Session start timestamp.
  final DateTime startedAt;

  /// Optional completion timestamp.
  final DateTime? completedAt;

  /// Package version string.
  final String packageVersion;

  /// Whether a face was detected during the session.
  final bool faceDetected;

  /// Whether multiple faces were detected.
  final bool multipleFacesDetected;

  /// Step summaries (derived signals only).
  final List<Map<String, Object?>> steps;

  /// Timeline of privacy-safe audit trail events.
  final List<Map<String, Object?>> events;

  /// Whether raw images were stored (always false by default).
  final bool rawImagesStored;

  /// Identity decision marker (not performed by this package).
  final String identityDecision;

  /// Credit decision marker (not performed by this package).
  final String creditDecision;

  /// Demo-only marker.
  final bool demoOnly;

  /// Diagnostics snapshot.
  final Map<String, Object?> diagnostics;

  /// Privacy flags.
  final Map<String, Object?> privacy;

  /// Serializes the audit event to JSON-compatible maps.
  Map<String, Object?> toJson() => <String, Object?>{
        'sessionId': sessionId,
        'sequenceId': sequenceId,
        'challengeNonce': challengeNonce,
        'startedAt': startedAt.toUtc().toIso8601String(),
        'completedAt': completedAt?.toUtc().toIso8601String(),
        'packageVersion': packageVersion,
        'faceDetected': faceDetected,
        'multipleFacesDetected': multipleFacesDetected,
        'steps': steps,
        'events': events,
        'rawImagesStored': rawImagesStored,
        'identityDecision': identityDecision,
        'creditDecision': creditDecision,
        'demoOnly': demoOnly,
        'diagnostics': diagnostics,
        'privacy': privacy,
      };

  @override
  List<Object?> get props => [
        sessionId,
        sequenceId,
        challengeNonce,
        startedAt,
        completedAt,
        packageVersion,
        faceDetected,
        multipleFacesDetected,
        steps,
        events,
        rawImagesStored,
        identityDecision,
        creditDecision,
        demoOnly,
        diagnostics,
        privacy,
      ];
}

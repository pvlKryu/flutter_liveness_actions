import 'package:equatable/equatable.dart';

/// onboarding audit event.
class OnboardingAuditEvent extends Equatable {
  /// Creates an instance with optional overrides.
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
    this.rawImagesStored = false,
    this.identityDecision = 'not_performed',
    this.creditDecision = 'not_performed',
    this.demoOnly = true,
    this.diagnostics = const <String, Object?>{},
    this.privacy = const <String, Object?>{},
  });

  /// session id.
  final String sessionId;

  /// sequence id.
  final String sequenceId;

  /// challenge nonce.
  final String? challengeNonce;

  /// started at.
  final DateTime startedAt;

  /// completed at.
  final DateTime? completedAt;

  /// package version.
  final String packageVersion;

  /// face detected.
  final bool faceDetected;

  /// multiple faces detected.
  final bool multipleFacesDetected;

  /// steps.
  final List<Map<String, Object?>> steps;

  /// raw images stored.
  final bool rawImagesStored;

  /// identity decision.
  final String identityDecision;

  /// credit decision.
  final String creditDecision;

  /// demo only.
  final bool demoOnly;

  /// diagnostics.
  final Map<String, Object?> diagnostics;

  /// privacy.
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
        'rawImagesStored': rawImagesStored,
        'identityDecision': identityDecision,
        'creditDecision': creditDecision,
        'demoOnly': demoOnly,
        'diagnostics': diagnostics,
        'privacy': privacy,
      };

  @override

  /// props.
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
        rawImagesStored,
        identityDecision,
        creditDecision,
        demoOnly,
        diagnostics,
        privacy,
      ];
}

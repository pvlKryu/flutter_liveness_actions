import '../models/challenge_state.dart';
import '../models/challenge_step.dart';
import '../models/liveness_diagnostics.dart';
import '../models/onboarding_audit_event.dart';
import '../privacy/privacy_guard.dart';

/// audit event builder.
class AuditEventBuilder {
  /// Creates a builder for a challenge session audit trail.
  AuditEventBuilder({
    required this.sessionId,
    required this.sequenceId,
    required this.packageVersion,
    PrivacyGuard? privacyGuard,
    DateTime? startedAt,
    this.challengeNonce,
  })  : _privacyGuard = privacyGuard ?? const PrivacyGuard(),
        _startedAt = startedAt ?? DateTime.now();

  /// session id.
  final String sessionId;

  /// sequence id.
  final String sequenceId;

  /// challenge nonce.
  final String? challengeNonce;

  /// package version.
  final String packageVersion;

  ///  privacy guard.
  final PrivacyGuard _privacyGuard;

  ///  started at.
  final DateTime _startedAt;

  /// Builds a privacy-safe [OnboardingAuditEvent] from challenge state.
  OnboardingAuditEvent build({
    required FaceChallengeState challengeState,
    required bool faceDetected,
    required bool multipleFacesDetected,
    required LivenessDiagnostics diagnostics,
    DateTime? completedAt,
  }) {
    return OnboardingAuditEvent(
      sessionId: sessionId,
      sequenceId: sequenceId,
      challengeNonce: challengeNonce,
      startedAt: _startedAt,
      completedAt: completedAt,
      packageVersion: packageVersion,
      faceDetected: faceDetected,
      multipleFacesDetected: multipleFacesDetected,
      steps: challengeState.steps.map(_stepToMap).toList(growable: false),
      rawImagesStored: false,
      identityDecision: 'not_performed',
      creditDecision: 'not_performed',
      demoOnly: true,
      diagnostics: diagnostics.toJson(),
      privacy: _privacyGuard.auditPrivacyFlags(),
    );
  }

  ///  step to map.
  Map<String, Object?> _stepToMap(FaceChallengeStep step) {
    final durationMs = step.startedAt == null || step.completedAt == null
        ? null
        : step.completedAt!.difference(step.startedAt!).inMilliseconds;
    return <String, Object?>{
      'id': step.id,
      'type': step.type.name,
      'status': step.status.name,
      'durationMs': durationMs,
      'retryCount': step.retryCount,
      'failureReason': step.failureReason.name,
    };
  }
}

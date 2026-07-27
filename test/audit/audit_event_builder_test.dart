import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

void main() {
  group('AuditEventBuilder', () {
    test('serializes to JSON', () {
      final builder = AuditEventBuilder(
        sessionId: 'demo-session-123',
        sequenceId: 'sequence-001',
        packageVersion: '0.1.0',
      );
      final event = builder.build(
        challengeState: FaceChallengeState.initial(
          DefaultChallenges.defaultSequence().steps,
        ),
        faceDetected: true,
        multipleFacesDetected: false,
        diagnostics: const LivenessDiagnostics(),
      );
      final json = jsonEncode(event.toJson());
      expect(json, contains('demo-session-123'));
      expect(json, contains('sequence-001'));
    });

    test('includes privacy flags', () {
      final builder = AuditEventBuilder(
        sessionId: 's1',
        sequenceId: 'seq1',
        packageVersion: '0.1.0',
      );
      final event = builder.build(
        challengeState: FaceChallengeState.initial(
          DefaultChallenges.defaultSequence().steps,
        ),
        faceDetected: true,
        multipleFacesDetected: false,
        diagnostics: const LivenessDiagnostics(),
      );
      expect(event.privacy['derivedSignalsOnly'], isTrue);
      expect(event.privacy['rawImagesStored'], isFalse);
    });

    test('does not include raw image data', () {
      final builder = AuditEventBuilder(
        sessionId: 's1',
        sequenceId: 'seq1',
        packageVersion: '0.1.0',
      );
      final event = builder.build(
        challengeState: FaceChallengeState.initial(
          DefaultChallenges.defaultSequence().steps,
        ),
        faceDetected: true,
        multipleFacesDetected: false,
        diagnostics: const LivenessDiagnostics(),
      );
      final json = jsonEncode(event.toJson());
      expect(json.contains('"imageBytes"'), isFalse);
      expect(json.contains('"cameraFrame"'), isFalse);
    });

    test('marks identityDecision as not_performed', () {
      final builder = AuditEventBuilder(
        sessionId: 's1',
        sequenceId: 'seq1',
        packageVersion: '0.1.0',
      );
      final event = builder.build(
        challengeState: FaceChallengeState.initial(
          DefaultChallenges.defaultSequence().steps,
        ),
        faceDetected: true,
        multipleFacesDetected: false,
        diagnostics: const LivenessDiagnostics(),
      );
      expect(event.identityDecision, 'not_performed');
    });

    test('marks creditDecision as not_performed', () {
      final builder = AuditEventBuilder(
        sessionId: 's1',
        sequenceId: 'seq1',
        packageVersion: '0.1.0',
      );
      final event = builder.build(
        challengeState: FaceChallengeState.initial(
          DefaultChallenges.defaultSequence().steps,
        ),
        faceDetected: true,
        multipleFacesDetected: false,
        diagnostics: const LivenessDiagnostics(),
      );
      expect(event.creditDecision, 'not_performed');
    });
  });
}

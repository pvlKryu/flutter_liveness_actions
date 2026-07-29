import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

void main() {
  group('AuditEventBuilder', () {
    test('serializes to JSON', () {
      final builder = AuditEventBuilder(
        sessionId: 'demo-session-123',
        sequenceId: 'sequence-001',
        packageVersion: packageVersion,
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
        packageVersion: packageVersion,
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

    test('includes performance profile and effective FPS', () {
      final builder = AuditEventBuilder(
        sessionId: 's1',
        sequenceId: 'seq1',
        packageVersion: packageVersion,
      );
      final event = builder.build(
        challengeState: FaceChallengeState.initial(
          DefaultChallenges.defaultSequence().steps,
        ),
        faceDetected: true,
        multipleFacesDetected: false,
        diagnostics: const LivenessDiagnostics(
          averageProcessingMs: 50,
          processedFrames: 10,
          droppedFrames: 1,
          targetProcessingFps: 12,
        ),
        performanceConfig: PerformanceConfig.lowEndDevice(),
      );
      expect(event.performance['profile'], 'lowEndDevice');
      expect(event.performance['targetProcessingFps'], 8);
      expect(event.performance['averageProcessingMs'], 50);
      expect(event.performance['effectiveProcessingFps'], closeTo(20.0, 0.001));
      expect(
        event.events.any((e) => e['type'] == 'performanceContext'),
        isTrue,
      );
    });

    test('privacy flags remain immutable even with permissive PrivacyGuard',
        () {
      final builder = AuditEventBuilder(
        sessionId: 's1',
        sequenceId: 'seq1',
        packageVersion: packageVersion,
        privacyGuard: const PrivacyGuard(
          config: PrivacyConfig(
            allowRawImageStorage: true,
            allowRawImageUpload: true,
            derivedSignalsOnly: false,
          ),
        ),
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
      expect(event.rawImagesStored, isFalse);
    });

    test('does not include raw image data', () {
      final builder = AuditEventBuilder(
        sessionId: 's1',
        sequenceId: 'seq1',
        packageVersion: packageVersion,
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
        packageVersion: packageVersion,
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
        packageVersion: packageVersion,
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

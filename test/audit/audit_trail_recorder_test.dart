import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

void main() {
  group('AuditTrailRecorder', () {
    test('records events and serializes to json', () {
      final recorder = AuditTrailRecorder();
      recorder.record(AuditTrailEventType.cameraReady);
      recorder.record(
        AuditTrailEventType.stepPassed,
        stepId: 'step-1',
        stepType: 'blink_once',
      );

      expect(recorder.entries, hasLength(2));
      final json = recorder.toJsonList();
      expect(json.first['type'], 'cameraReady');
      expect(json.last['stepId'], 'step-1');
    });
  });

  group('AuditEventBuilder trail', () {
    test('includes events timeline in audit output', () {
      final builder = AuditEventBuilder(
        sessionId: 's1',
        sequenceId: 'seq1',
        packageVersion: '0.3.0',
      );
      builder.recordCameraReady();
      builder.recordQualityGatePassed();

      final event = builder.build(
        challengeState: FaceChallengeState.initial(
          DefaultChallenges.defaultSequence().steps,
        ),
        faceDetected: true,
        multipleFacesDetected: false,
        diagnostics: const LivenessDiagnostics(),
      );

      expect(event.events, isNotEmpty);
      expect(event.events.first['type'], 'sessionStarted');
    });
  });
}

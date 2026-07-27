import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../test_helpers.dart';

void main() {
  group('LivenessActionSession', () {
    test('processes frames and exposes guidance', () {
      final session = LivenessActionSession(
        performanceConfig: PerformanceConfig.highPerformance(),
      );
      addTearDown(session.dispose);

      LivenessActionSnapshot? snap;
      for (var i = 0; i < 4; i++) {
        final next = session.processFrame(
          TestFrames.centeredFace(
            timestamp: DateTime.fromMillisecondsSinceEpoch(i * 200),
          ),
          processingDuration: const Duration(milliseconds: 20),
        );
        if (next != null) {
          snap = next;
        }
      }

      expect(snap, isNotNull);
      expect(snap!.result.signal.faceDetected, isTrue);
      expect(session.latestResult, isNotNull);
      expect(session.diagnostics.processedFrames, greaterThan(0));
    });

    test('drops frames when paused', () {
      final session = LivenessActionSession(
        performanceConfig: PerformanceConfig.highPerformance(),
      );
      addTearDown(session.dispose);

      session.pause();
      final snap = session.processFrame(
        TestFrames.centeredFace(
          timestamp: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
      expect(snap, isNull);
      expect(session.diagnostics.droppedFrames, greaterThan(0));
    });

    test('runs challenge steps when enabled', () {
      final session = LivenessActionSession(
        enableChallenge: true,
        challengeConfig: const FaceChallengeConfig(
          maxSteps: 2,
          allowedSteps: <FaceActionType>[
            FaceActionType.centerFace,
            FaceActionType.blinkOnce,
          ],
          requireCenterFaceFirst: true,
        ),
        performanceConfig: PerformanceConfig.highPerformance(),
        sessionId: 'test-challenge',
      );
      addTearDown(session.dispose);

      expect(session.challenge, isNotNull);
      expect(session.challenge!.sequence.steps, isNotEmpty);

      for (var i = 0; i < 8; i++) {
        session.processFrame(
          TestFrames.centeredFace(
            timestamp: DateTime.fromMillisecondsSinceEpoch(i * 250),
          ),
          processingDuration: const Duration(milliseconds: 15),
        );
      }

      expect(
        session.challenge!.state.steps.first.status,
        anyOf(ChallengeStepStatus.passed, ChallengeStepStatus.inProgress),
      );

      final audit = session.buildAuditEvent();
      expect(audit.sessionId, 'test-challenge');
      expect(audit.packageVersion, packageVersion);
      expect(audit.events, isNotEmpty);
      expect(audit.demoOnly, isTrue);
    });

    test('throws after dispose', () {
      final session = LivenessActionSession();
      session.dispose();
      expect(
        () => session.processFrame(TestFrames.centeredFace()),
        throwsStateError,
      );
    });
  });
}

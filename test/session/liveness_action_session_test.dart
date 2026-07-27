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
      expect(audit.identityDecision, 'not_performed');
      expect(audit.rawImagesStored, isFalse);
    });

    test('reset rebuilds challenge and clears latest result', () {
      final session = LivenessActionSession(
        enableChallenge: true,
        performanceConfig: PerformanceConfig.highPerformance(),
      );
      addTearDown(session.dispose);

      session.processFrame(
        TestFrames.centeredFace(
          timestamp: DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
      expect(session.latestResult, isNotNull);
      final firstId = session.challenge!.sequence.sequenceId;
      session.reset();
      expect(session.latestResult, isNull);
      expect(session.challenge!.sequence.sequenceId, firstId);
      expect(session.challenge!.state.completed, isFalse);
    });

    test('resume after pause accepts frames again', () {
      final session = LivenessActionSession(
        performanceConfig: PerformanceConfig.highPerformance(),
      );
      addTearDown(session.dispose);

      session.pause();
      expect(
        session.processFrame(
          TestFrames.centeredFace(
            timestamp: DateTime.fromMillisecondsSinceEpoch(0),
          ),
        ),
        isNull,
      );
      session.resume();
      expect(
        session.processFrame(
          TestFrames.centeredFace(
            timestamp: DateTime.fromMillisecondsSinceEpoch(200),
          ),
          processingDuration: const Duration(milliseconds: 10),
        ),
        isNotNull,
      );
    });

    test('throws after dispose', () {
      final session = LivenessActionSession();
      session.dispose();
      expect(
        () => session.processFrame(TestFrames.centeredFace()),
        throwsStateError,
      );
    });

    test('markProcessingFailed releases busy state and allows next frame', () {
      final session = LivenessActionSession(
        performanceConfig: PerformanceConfig.highPerformance(),
      );
      addTearDown(session.dispose);

      final t0 = DateTime.fromMillisecondsSinceEpoch(0);
      expect(session.acceptFrame(t0), isTrue);
      session.markProcessingStarted();
      session.markProcessingFailed();

      expect(session.diagnostics.droppedFrames, 1);
      expect(session.diagnostics.processedFrames, 0);

      final snap = session.processFrame(
        TestFrames.centeredFace(
          timestamp: DateTime.fromMillisecondsSinceEpoch(200),
        ),
        processingDuration: const Duration(milliseconds: 10),
      );
      expect(snap, isNotNull);
    });

    test('markProcessingFailed can skip dropped-frame increment', () {
      final session = LivenessActionSession(
        performanceConfig: PerformanceConfig.highPerformance(),
      );
      addTearDown(session.dispose);

      expect(
          session.acceptFrame(DateTime.fromMillisecondsSinceEpoch(0)), isTrue);
      session.markProcessingStarted();
      session.markProcessingFailed(countAsDropped: false);
      expect(session.diagnostics.droppedFrames, 0);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../test_helpers.dart';

void main() {
  group('ChallengeFlowController', () {
    late ChallengeFlowController controller;

    setUp(() {
      controller = ChallengeFlowController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('completes default sequence', () {
      final types = controller.state.steps.map((s) => s.type).toList();
      for (final type in types) {
        controller.processSignal(signalForStep(type));
      }
      expect(controller.state.completed, isTrue);
      expect(controller.state.progress, 1.0);
    });

    test('fails on timeout', () {
      controller.dispose();
      controller = ChallengeFlowController(
        config: const FaceChallengeConfig(maxRetriesPerStep: 0),
      );
      final start = DateTime(2026, 1, 1, 12);
      controller.processSignal(FaceActionSignal.empty(), now: start);
      controller.processSignal(
        FaceActionSignal.empty(),
        now: start.add(const Duration(seconds: 20)),
      );
      expect(controller.state.failed, isTrue);
    });

    test('supports retry', () async {
      controller.dispose();
      controller = ChallengeFlowController(
        config: const FaceChallengeConfig(maxRetriesPerStep: 2),
      );
      final events = <FaceChallengeEventType>[];
      controller.events.listen((e) => events.add(e.type));
      final start = DateTime(2026, 1, 1, 12);
      controller.processSignal(FaceActionSignal.empty(), now: start);
      controller.processSignal(
        FaceActionSignal.empty(),
        now: start.add(const Duration(seconds: 20)),
      );
      await Future<void>.delayed(Duration.zero);
      expect(events, contains(FaceChallengeEventType.retryRequested));
    });

    test('supports reset', () {
      controller.processSignal(signalForStep(FaceActionType.centerFace));
      controller.reset();
      expect(controller.state.progress, 0);
      expect(controller.state.completed, isFalse);
    });

    test('emits events', () async {
      controller.dispose();
      controller = ChallengeFlowController();
      final events = <FaceChallengeEventType>[];
      controller.events.listen((e) => events.add(e.type));
      controller.reset();
      controller.processSignal(signalForStep(FaceActionType.centerFace));
      await Future<void>.delayed(Duration.zero);
      expect(events, contains(FaceChallengeEventType.challengeStarted));
      expect(events, contains(FaceChallengeEventType.stepPassed));
    });

    test('calculates progress', () {
      controller.processSignal(signalForStep(FaceActionType.centerFace));
      expect(controller.state.progress, closeTo(0.2, 0.01));
    });
  });
}

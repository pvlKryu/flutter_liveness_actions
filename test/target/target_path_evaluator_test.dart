import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

void main() {
  group('TargetPathEvaluator', () {
    late TargetPathEvaluator evaluator;
    late List<TargetZone> zones;
    const sim = TargetChallengeSimulator();

    setUp(() {
      zones = DefaultTargetPaths.simpleCross(
        config: const FaceActionConfig(
          targetHoldDuration: Duration(milliseconds: 200),
          requiredTargetStableFrames: 2,
          targetTimeout: Duration(seconds: 5),
        ),
      );
      evaluator = TargetPathEvaluator(
        targets: zones,
        sequenceId: 'test-path',
        config: const FaceActionConfig(
          targetHoldDuration: Duration(milliseconds: 200),
          requiredTargetStableFrames: 2,
          targetTimeout: Duration(seconds: 5),
        ),
      );
    });

    test('face inside target completes after hold duration', () {
      final frames = sim.successPath(zones: zones, holdFrames: 5);
      TargetZoneResult? last;
      for (final frame in frames) {
        last = evaluator.processFrame(frame);
      }
      expect(evaluator.state.completed, isTrue);
      expect(last!.pathCompleted, isTrue);
      expect(evaluator.state.completedTargets, zones.length);
    });

    test('face outside target does not complete', () {
      final t = DateTime.utc(2026, 1, 1);
      final frame = sim.frameWithFaceCenter(
        timestamp: t,
        centerX: 0.05,
        centerY: 0.05,
      );
      final result = evaluator.processFrame(frame);
      expect(result.inside, isFalse);
      expect(result.completed, isFalse);
      expect(evaluator.state.completed, isFalse);
    });

    test('target timeout fails', () {
      final frames = sim.followTargetTimeoutFailure();
      for (final frame in frames) {
        evaluator.processFrame(frame);
      }
      expect(evaluator.state.failed, isTrue);
      expect(evaluator.state.failureReason, ChallengeFailureReason.timeout);
    });

    test('face lost eventually fails', () {
      final frames = sim.followTargetFaceLostFailure();
      for (final frame in frames) {
        evaluator.processFrame(frame);
      }
      expect(evaluator.state.failed, isTrue);
      expect(
        evaluator.state.failureReason,
        anyOf(ChallengeFailureReason.lostFace, ChallengeFailureReason.timeout),
      );
    });

    test('multiple faces rejected', () {
      final frames = sim.followTargetMultipleFacesFailure();
      for (final frame in frames) {
        evaluator.processFrame(frame);
      }
      expect(evaluator.state.failed, isTrue);
      expect(
        evaluator.state.failureReason,
        ChallengeFailureReason.multipleFaces,
      );
    });

    test('normalized center calculation correct', () {
      final frame = sim.frameWithFaceCenter(
        timestamp: DateTime.utc(2026, 1, 1),
        centerX: 0.25,
        centerY: 0.75,
      );
      final position = FaceTargetPosition.fromFrame(frame);
      expect(position.isValid, isTrue);
      expect(position.centerX, closeTo(0.25, 0.05));
      expect(position.centerY, closeTo(0.75, 0.05));
      expect(position.areaRatio, greaterThan(0));
    });

    test('distance calculation correct', () {
      const position = FaceTargetPosition(
        centerX: 0.5,
        centerY: 0.5,
        areaRatio: 0.2,
        isValid: true,
      );
      expect(position.distanceToPoint(0.5, 0.5), 0);
      expect(position.distanceToPoint(0.6, 0.5), closeTo(0.1, 0.0001));
    });
  });

  group('TargetPathFactory', () {
    const factory = TargetPathFactory();

    test('simpleCross returns expected zones', () {
      final zones = factory.simpleCross();
      expect(zones.map((z) => z.id).toList(),
          ['center', 'left', 'right', 'center-return']);
    });

    test('corners returns expected zones', () {
      final zones = factory.corners();
      expect(zones.first.id, 'center');
      expect(zones.last.id, 'center-return');
      expect(zones.length, 6);
    });

    test('randomized with seed is deterministic', () {
      final a = factory.randomized(seed: 42, maxSteps: 4);
      final b = factory.randomized(seed: 42, maxSteps: 4);
      expect(a.map((z) => z.id), b.map((z) => z.id));
    });

    test('lowEndFriendly uses larger radius / fewer targets', () {
      final low = factory.lowEndFriendly();
      final cross = factory.simpleCross();
      expect(low.length, lessThanOrEqualTo(cross.length));
      expect(low.every((z) => z.radius >= 0.20), isTrue);
    });
  });
}

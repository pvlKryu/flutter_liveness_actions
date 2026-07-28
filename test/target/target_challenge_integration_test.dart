import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../test_helpers.dart';

void main() {
  group('Target challenge integration', () {
    const sim = TargetChallengeSimulator();

    test('followTargetPath step can complete', () {
      final controller = ChallengeFlowController(
        config: const FaceChallengeConfig(maxRetriesPerStep: 0),
        sequenceFactory: _FixedSequenceFactory(
          DefaultChallenges.followTargetSimple(),
        ),
      );
      addTearDown(controller.dispose);

      for (final frame in sim.followTargetSimpleSuccess()) {
        controller.processFrame(frame);
      }
      expect(controller.state.completed, isTrue);
    });

    test('lowEndFriendly challenge remains simple', () {
      final sequence = DefaultChallenges.lowEndFriendly();
      expect(sequence.steps.length, 3);
      expect(
        sequence.steps.map((s) => s.type),
        [
          FaceActionType.centerFace,
          FaceActionType.blinkOnce,
          FaceActionType.holdStill,
        ],
      );
    });

    test(
        'extended challenge includes follow target and can complete in simulator',
        () {
      final sequence = DefaultChallenges.extended();
      expect(
        sequence.steps.any((s) => s.type == FaceActionType.followTargetPath),
        isTrue,
      );

      final controller = ChallengeFlowController(
        config: const FaceChallengeConfig(maxRetriesPerStep: 0),
        sequenceFactory: _FixedSequenceFactory(sequence),
      );
      addTearDown(controller.dispose);

      // Drive signal-based steps, then target path frames, then hold still.
      for (final step in sequence.steps) {
        if (step.type == FaceActionType.followTargetPath) {
          for (final frame in sim.successPath(zones: step.targetZones!)) {
            controller.processFrame(frame);
          }
        } else if (step.type == FaceActionType.smile) {
          controller.processSignal(
            signalForStep(FaceActionType.smile),
          );
        } else {
          controller.processSignal(signalForStep(step.type));
        }
      }
      expect(controller.state.completed, isTrue);
    });
  });

  group('TargetChallengeSimulator scenarios', () {
    const sim = TargetChallengeSimulator();

    test('followTargetSimpleSuccess completes', () {
      final evaluator = TargetPathEvaluator(
        targets: DefaultTargetPaths.simpleCross(),
      );
      for (final frame in sim.followTargetSimpleSuccess()) {
        evaluator.processFrame(frame);
      }
      expect(evaluator.state.completed, isTrue);
    });

    test('followTargetCornersSuccess completes', () {
      final evaluator = TargetPathEvaluator(
        targets: DefaultTargetPaths.corners(),
      );
      for (final frame in sim.followTargetCornersSuccess()) {
        evaluator.processFrame(frame);
      }
      expect(evaluator.state.completed, isTrue);
    });

    test('followTargetTimeoutFailure fails', () {
      final evaluator = TargetPathEvaluator(
        targets: DefaultTargetPaths.simpleCross(),
      );
      for (final frame in sim.followTargetTimeoutFailure()) {
        evaluator.processFrame(frame);
      }
      expect(evaluator.state.failed, isTrue);
    });

    test('noisy target path still completes if within tolerance', () {
      final evaluator = TargetPathEvaluator(
        targets: DefaultTargetPaths.lowEndFriendly(),
      );
      for (final frame in sim.followTargetNoisyButSuccess()) {
        evaluator.processFrame(frame);
      }
      expect(evaluator.state.completed, isTrue);
    });

    test('generated frames contain no raw images', () {
      final frame = sim.frameWithFaceCenter(
        timestamp: DateTime.utc(2026, 1, 1),
        centerX: 0.5,
        centerY: 0.5,
      );
      expect(frame.metadata.containsKey('bytes'), isFalse);
      expect(frame.boundingBox, isNotNull);
    });
  });
}

class _FixedSequenceFactory extends ChallengeSequenceFactory {
  _FixedSequenceFactory(this._sequence);
  final FaceChallengeSequence _sequence;

  @override
  FaceChallengeSequence create(FaceChallengeConfig config) => _sequence;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../test_helpers.dart';

void main() {
  group('ChallengeStepEvaluator', () {
    const evaluator = ChallengeStepEvaluator();

    FaceChallengeStep step(FaceActionType type) => FaceChallengeStep(
          id: type.name,
          type: type,
          instruction: type.name,
          status: ChallengeStepStatus.inProgress,
        );

    test('matches each action type', () {
      expect(
        evaluator.evaluate(
          step(FaceActionType.centerFace),
          signalForStep(FaceActionType.centerFace),
        ),
        isTrue,
      );
      expect(
        evaluator.evaluate(
          step(FaceActionType.blinkOnce),
          signalForStep(FaceActionType.blinkOnce),
        ),
        isTrue,
      );
      expect(
        evaluator.evaluate(
          step(FaceActionType.turnHeadLeft),
          signalForStep(FaceActionType.turnHeadLeft),
        ),
        isTrue,
      );
      expect(
        evaluator.evaluate(
          step(FaceActionType.turnHeadRight),
          signalForStep(FaceActionType.turnHeadRight),
        ),
        isTrue,
      );
      expect(
        evaluator.evaluate(
          step(FaceActionType.holdStill),
          signalForStep(FaceActionType.holdStill),
        ),
        isTrue,
      );
    });

    test('rejects mismatched signals', () {
      expect(
        evaluator.evaluate(
          step(FaceActionType.blinkOnce),
          signalForStep(FaceActionType.centerFace),
        ),
        isFalse,
      );
    });
  });
}

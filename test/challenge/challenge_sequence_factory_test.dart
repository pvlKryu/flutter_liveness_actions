import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

void main() {
  group('ChallengeSequenceFactory', () {
    const factory = ChallengeSequenceFactory();

    test('creates deterministic randomized sequence from seed', () {
      const config = FaceChallengeConfig(
        randomize: true,
        seed: 42,
        sequenceIdPrefix: 'random',
        maxSteps: 4,
      );
      final a = factory.create(config);
      final b = factory.create(config);
      expect(a.sequenceId, 'random-42');
      expect(a.sequenceId, b.sequenceId);
      expect(a.challengeNonce, b.challengeNonce);
      expect(a.steps.map((s) => s.type), b.steps.map((s) => s.type));
    });

    test('puts center face first when required', () {
      final sequence = factory.create(
        const FaceChallengeConfig(
          randomize: true,
          seed: 7,
          requireCenterFaceFirst: true,
          maxSteps: 4,
        ),
      );
      expect(sequence.steps.first.type, FaceActionType.centerFace);
    });

    test('does not duplicate steps by default', () {
      final sequence = factory.create(
        const FaceChallengeConfig(
          randomize: true,
          seed: 99,
          maxSteps: 5,
        ),
      );
      final types = sequence.steps.map((s) => s.type).toList();
      expect(types.toSet().length, types.length);
    });
  });
}

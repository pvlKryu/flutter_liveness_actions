import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../test_helpers.dart';

void main() {
  group('FaceQualityGate', () {
    late FaceQualityGate gate;

    setUp(() {
      gate = FaceQualityGate(requiredStableFrames: 2);
    });

    test('accepts good face state', () {
      gate.evaluate(TestFrames.centeredFace());
      final result = gate.evaluate(TestFrames.centeredFace());
      expect(result.isAcceptable, isTrue);
      expect(result.status, FaceQualityStatus.acceptable);
    });

    test('rejects multiple faces', () {
      final result = gate.evaluate(TestFrames.multipleFaces());
      expect(result.isAcceptable, isFalse);
      expect(result.status, FaceQualityStatus.multipleFaces);
    });

    test('rejects face too far', () {
      final result = gate.evaluate(
        TestFrames.faceAt(box: const Rect.fromLTWH(450, 450, 80, 80)),
      );
      expect(result.isAcceptable, isFalse);
      expect(result.status, FaceQualityStatus.tooFar);
    });

    test('rejects face out of frame', () {
      final result = gate.evaluate(
        TestFrames.faceAt(box: const Rect.fromLTWH(-10, 200, 400, 500)),
      );
      expect(result.isAcceptable, isFalse);
      expect(result.status, FaceQualityStatus.outOfFrame);
    });
  });
}

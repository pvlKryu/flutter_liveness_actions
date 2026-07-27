import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../test_helpers.dart';

void main() {
  group('FacePositionAnalyzer', () {
    const analyzer = FacePositionAnalyzer();

    test('no face', () {
      expect(
        analyzer.analyze(TestFrames.noFace()).name,
        FacePositionStatus.noFace.name,
      );
    });

    test('multiple faces', () {
      expect(
        analyzer.analyze(TestFrames.multipleFaces()).name,
        FacePositionStatus.multipleFaces.name,
      );
    });

    test('centered face', () {
      expect(
        analyzer.analyze(TestFrames.centeredFace()).name,
        FacePositionStatus.centered.name,
      );
    });

    test('too close', () {
      final frame = TestFrames.faceAt(
        box: const Rect.fromLTWH(100, 100, 800, 800),
      );
      expect(analyzer.analyze(frame).name, FacePositionStatus.tooClose.name);
    });

    test('too far', () {
      final frame = TestFrames.faceAt(
        box: const Rect.fromLTWH(450, 450, 80, 80),
      );
      expect(analyzer.analyze(frame).name, FacePositionStatus.tooFar.name);
    });

    test('out of frame', () {
      final frame = TestFrames.faceAt(
        box: const Rect.fromLTWH(-10, 200, 400, 500),
      );
      expect(analyzer.analyze(frame).name, FacePositionStatus.outOfFrame.name);
    });
  });
}

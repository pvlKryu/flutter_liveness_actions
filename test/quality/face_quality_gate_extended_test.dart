import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../test_helpers.dart';

void main() {
  group('FaceQualityGate extended checks', () {
    test('adds low light heuristic warning without hard-failing', () {
      final gate = FaceQualityGate(
        requiredStableFrames: 1,
        enableExtendedQualityChecks: true,
      );
      final frame = TestFrames.centeredFace().withBrightness(0.1);
      final result = gate.evaluate(frame);
      expect(result.isAcceptable, isTrue);
      expect(result.warnings, contains(FaceQualityWarning.lowLightHeuristic));
    });

    test('maps notCentered position to quality status', () {
      final gate = FaceQualityGate(requiredStableFrames: 1);
      final frame = TestFrames.faceAt(
        box: const Rect.fromLTWH(50, 200, 300, 400),
      );
      final result = gate.evaluate(frame);
      expect(result.status, FaceQualityStatus.notCentered);
    });
  });
}

extension on FaceActionFrame {
  FaceActionFrame withBrightness(double value) {
    return FaceActionFrame(
      timestamp: timestamp,
      faceDetected: faceDetected,
      faceCount: faceCount,
      leftEyeOpenProbability: leftEyeOpenProbability,
      rightEyeOpenProbability: rightEyeOpenProbability,
      smilingProbability: smilingProbability,
      headEulerAngleY: headEulerAngleY,
      headEulerAngleZ: headEulerAngleZ,
      boundingBox: boundingBox,
      imageSize: imageSize,
      hasContours: hasContours,
      hasLandmarks: hasLandmarks,
      brightnessHeuristic: value,
      metadata: metadata,
    );
  }
}

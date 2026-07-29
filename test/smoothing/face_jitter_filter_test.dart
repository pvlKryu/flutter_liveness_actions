import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

void main() {
  group('FaceJitterFilter', () {
    test('averages yaw/pitch/roll over the rolling window', () {
      final filter = FaceJitterFilter(windowSize: 5);
      final base = DateTime(2026, 1, 1);

      for (var i = 0; i < 5; i++) {
        filter.filter(
          FaceActionFrame(
            timestamp: base.add(Duration(milliseconds: i * 50)),
            faceDetected: true,
            faceCount: 1,
            headEulerAngleX: i.toDouble(), // 0..4 avg 2
            headEulerAngleY: (i * 2).toDouble(), // 0,2,4,6,8 avg 4
            headEulerAngleZ: 10,
            boundingBox: Rect.fromLTWH(100.0 + i, 200.0 + i, 100, 100),
            imageSize: const Size(1000, 1000),
          ),
        );
      }

      final current = filter.current!;
      expect(current.headEulerAngleX, closeTo(2.0, 0.001));
      expect(current.headEulerAngleY, closeTo(4.0, 0.001));
      expect(current.headEulerAngleZ, closeTo(10.0, 0.001));
      expect(current.centerX, isNotNull);
      expect(current.centerY, isNotNull);
      expect(current.sampleCount, 5);
    });

    test('returns smoothed frame without mutating non-geometry fields', () {
      final filter = FaceJitterFilter(windowSize: 3);
      final raw = FaceActionFrame(
        timestamp: DateTime(2026, 1, 1),
        faceDetected: true,
        faceCount: 1,
        leftEyeOpenProbability: 0.9,
        smilingProbability: 0.4,
        headEulerAngleY: 10,
        boundingBox: const Rect.fromLTWH(0, 0, 100, 100),
        imageSize: const Size(1000, 1000),
      );
      final smoothed = filter.filter(raw);
      expect(smoothed.leftEyeOpenProbability, 0.9);
      expect(smoothed.smilingProbability, 0.4);
      expect(smoothed.faceCount, 1);
      expect(smoothed.headEulerAngleY, 10);
    });

    test('does not poison buffers with missing optional metrics', () {
      final filter = FaceJitterFilter(windowSize: 3);
      filter.filter(
        FaceActionFrame(
          timestamp: DateTime(2026, 1, 1),
          faceDetected: true,
          faceCount: 1,
          headEulerAngleY: 5,
        ),
      );
      filter.filter(
        FaceActionFrame(
          timestamp: DateTime(2026, 1, 1, 0, 0, 1),
          faceDetected: true,
          faceCount: 1,
          // yaw missing this frame
        ),
      );
      expect(filter.current!.headEulerAngleY, 5);
      expect(filter.current!.headEulerAngleX, isNull);
    });

    test('reset clears buffers', () {
      final filter = FaceJitterFilter(windowSize: 3);
      filter.filter(
        FaceActionFrame(
          timestamp: DateTime(2026, 1, 1),
          faceDetected: true,
          faceCount: 1,
          headEulerAngleY: 8,
        ),
      );
      filter.reset();
      expect(filter.current, isNull);
      expect(filter.sampleCount, 0);
    });
  });
}

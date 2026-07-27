import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

void main() {
  group('BlinkDetector', () {
    late BlinkDetector detector;
    late DateTime baseTime;

    setUp(() {
      detector = BlinkDetector(
        config: const FaceActionConfig(),
        smoother: SignalSmoother(bufferSize: 1, requiredConsecutiveFrames: 1),
      );
      baseTime = DateTime(2026, 1, 1, 12);
    });

    test('detects blink when eyes close and reopen', () {
      var t = baseTime;
      expect(
        detector.update(
          leftEyeOpenProbability: 0.9,
          rightEyeOpenProbability: 0.9,
          timestamp: t,
        ),
        isFalse,
      );
      t = t.add(const Duration(milliseconds: 50));
      expect(
        detector.update(
          leftEyeOpenProbability: 0.05,
          rightEyeOpenProbability: 0.05,
          timestamp: t,
        ),
        isFalse,
      );
      t = t.add(const Duration(milliseconds: 50));
      expect(
        detector.update(
          leftEyeOpenProbability: 0.9,
          rightEyeOpenProbability: 0.9,
          timestamp: t,
        ),
        isTrue,
      );
    });

    test('does not detect blink from one noisy frame', () {
      detector.update(
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.9,
        timestamp: baseTime,
      );
      final detected = detector.update(
        leftEyeOpenProbability: 0.1,
        rightEyeOpenProbability: 0.1,
        timestamp: baseTime.add(const Duration(milliseconds: 16)),
      );
      expect(detected, isFalse);
    });

    test('fails on timeout', () {
      detector.update(
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.9,
        timestamp: baseTime,
      );
      detector.update(
        leftEyeOpenProbability: 0.1,
        rightEyeOpenProbability: 0.1,
        timestamp: baseTime.add(const Duration(milliseconds: 50)),
      );
      final detected = detector.update(
        leftEyeOpenProbability: 0.9,
        rightEyeOpenProbability: 0.9,
        timestamp: baseTime.add(const Duration(milliseconds: 1500)),
      );
      expect(detected, isFalse);
    });

    test('respects thresholds', () {
      final strict = BlinkDetector(
        config: const FaceActionConfig(
          eyeOpenThreshold: 0.8,
          eyeClosedThreshold: 0.2,
        ),
        smoother: SignalSmoother(bufferSize: 1, requiredConsecutiveFrames: 1),
      );
      strict.update(
        leftEyeOpenProbability: 0.85,
        rightEyeOpenProbability: 0.85,
        timestamp: baseTime,
      );
      strict.update(
        leftEyeOpenProbability: 0.15,
        rightEyeOpenProbability: 0.15,
        timestamp: baseTime.add(const Duration(milliseconds: 50)),
      );
      final detected = strict.update(
        leftEyeOpenProbability: 0.85,
        rightEyeOpenProbability: 0.85,
        timestamp: baseTime.add(const Duration(milliseconds: 100)),
      );
      expect(detected, isTrue);
    });
  });
}

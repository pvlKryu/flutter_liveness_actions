import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';
import 'package:flutter_liveness_actions/src/smoothing/hysteresis_threshold.dart';

void main() {
  group('SignalSmoother', () {
    test('smooths noisy probabilities', () {
      final smoother = SignalSmoother(bufferSize: 3);
      smoother.smoothEye(0.2);
      smoother.smoothEye(0.8);
      final avg = smoother.smoothEye(0.8);
      expect(avg, greaterThan(0.5));
      expect(avg, lessThan(0.8));
    });

    test('requires consecutive frames', () {
      final smoother = SignalSmoother(requiredConsecutiveFrames: 3);
      expect(smoother.stableBoolean(true), isFalse);
      expect(smoother.stableBoolean(true), isFalse);
      expect(smoother.stableBoolean(true), isTrue);
    });

    test('hysteresis works', () {
      final smoother = SignalSmoother(requiredConsecutiveFrames: 1);
      final threshold = HysteresisThreshold(
        onThreshold: 0.7,
        offThreshold: 0.3,
      );
      expect(
        smoother.stableHysteresis(value: 0.8, threshold: threshold),
        isTrue,
      );
      expect(
        smoother.stableHysteresis(value: 0.2, threshold: threshold),
        isFalse,
      );
    });
  });
}

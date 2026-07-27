import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

void main() {
  group('HeadMovementDetector', () {
    late HeadMovementDetector detector;

    setUp(() {
      detector = HeadMovementDetector();
    });

    test('detects left turn', () {
      final first = detector.detect(yaw: -20, roll: 0);
      expect(first.left, isFalse);
      final second = detector.detect(yaw: -20, roll: 0);
      expect(second.left, isTrue);
    });

    test('detects right turn', () {
      detector.detect(yaw: 20, roll: 0);
      final result = detector.detect(yaw: 20, roll: 0);
      expect(result.right, isTrue);
    });

    test('detects tilt', () {
      detector.detect(yaw: 0, roll: 18);
      final result = detector.detect(yaw: 0, roll: 18);
      expect(result.tilted, isTrue);
    });

    test('ignores small movement below threshold', () {
      detector.detect(yaw: -5, roll: 2);
      final result = detector.detect(yaw: -5, roll: 2);
      expect(result.left, isFalse);
      expect(result.right, isFalse);
      expect(result.tilted, isFalse);
    });
  });
}

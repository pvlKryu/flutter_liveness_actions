import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

void main() {
  group('LivenessSessionLifecycle', () {
    test('pause and resume', () {
      final lifecycle = LivenessSessionLifecycle();
      expect(lifecycle.isActive, isTrue);
      lifecycle.pause();
      expect(lifecycle.state, LivenessSessionLifecycleState.paused);
      lifecycle.resume();
      expect(lifecycle.isActive, isTrue);
    });

    test('dispose blocks further transitions', () {
      final lifecycle = LivenessSessionLifecycle();
      lifecycle.dispose();
      lifecycle.resume();
      expect(lifecycle.state, LivenessSessionLifecycleState.disposed);
    });
  });
}

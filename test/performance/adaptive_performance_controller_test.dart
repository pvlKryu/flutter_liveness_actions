import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

void main() {
  group('AdaptivePerformanceController', () {
    test('adapts to low-end after confirmation samples', () {
      final adaptive = AdaptivePerformanceController(confirmationSamples: 3);
      const slow = LivenessDiagnostics(
        averageProcessingMs: 130,
        processedFrames: 30,
        droppedFrames: 25,
        targetProcessingFps: 12,
      );

      expect(adaptive.observe(slow), isFalse);
      expect(adaptive.observe(slow), isFalse);
      expect(adaptive.observe(slow), isTrue);
      expect(adaptive.profile, PerformanceProfile.lowEndDevice);
    });

    test('forceProfile applies immediately', () {
      final adaptive = AdaptivePerformanceController();
      adaptive.forceProfile(PerformanceProfile.batterySaver);
      expect(adaptive.config.targetProcessingFps, 6);
    });
  });

  group('DeviceCapabilityProfile', () {
    test('recommends battery saver for very slow processing', () {
      final profile = DeviceCapabilityProfile.fromDiagnostics(
        const LivenessDiagnostics(
          averageProcessingMs: 180,
          processedFrames: 10,
          droppedFrames: 20,
        ),
      );
      expect(profile.recommendedProfile, PerformanceProfile.batterySaver);
      expect(profile.lowEndModeRecommended, isTrue);
    });

    test('recommends high performance for fast stable processing', () {
      final profile = DeviceCapabilityProfile.fromDiagnostics(
        const LivenessDiagnostics(
          averageProcessingMs: 25,
          processedFrames: 40,
          droppedFrames: 2,
        ),
      );
      expect(profile.recommendedProfile, PerformanceProfile.highPerformance);
    });
  });
}

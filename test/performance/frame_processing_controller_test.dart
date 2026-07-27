import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

void main() {
  group('FrameProcessingController', () {
    late FrameProcessingController controller;
    late DateTime baseTime;

    setUp(() {
      controller = FrameProcessingController(
        config: PerformanceConfig.balanced(),
      );
      baseTime = DateTime(2026, 1, 1, 12);
    });

    test('throttles FPS', () {
      expect(controller.shouldProcessFrame(baseTime), isTrue);
      controller.markProcessingStarted();
      controller.markProcessingCompleted(const Duration(milliseconds: 10));
      final tooSoon = baseTime.add(const Duration(milliseconds: 10));
      expect(controller.shouldProcessFrame(tooSoon), isFalse);
    });

    test('drops frames while busy', () {
      controller.markProcessingStarted();
      expect(controller.shouldProcessFrame(baseTime), isFalse);
      controller.markFrameDropped();
      final diagnostics = controller.diagnostics();
      expect(diagnostics.droppedFrames, greaterThan(0));
    });

    test('tracks latency', () {
      controller.markProcessingStarted();
      controller.markProcessingCompleted(const Duration(milliseconds: 25));
      expect(controller.diagnostics().averageProcessingMs, 25);
    });

    test('produces diagnostics', () {
      controller.markProcessingStarted();
      controller.markProcessingCompleted(const Duration(milliseconds: 10));
      final diagnostics = controller.diagnostics();
      expect(diagnostics.processedFrames, 1);
      expect(diagnostics.targetProcessingFps, 12);
    });
  });
}

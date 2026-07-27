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

    test('markProcessingFailed releases busy state', () {
      final high = FrameProcessingController(
        config: PerformanceConfig.highPerformance(),
      );
      final t = DateTime(2026, 1, 1, 12);
      expect(high.shouldProcessFrame(t), isTrue);

      high.markProcessingStarted();
      expect(high.isProcessing, isTrue);

      high.markProcessingFailed();

      expect(high.isProcessing, isFalse);
      expect(high.diagnostics().droppedFrames, 1);
      expect(high.diagnostics().processedFrames, 0);

      final later = t.add(const Duration(seconds: 1));
      expect(high.shouldProcessFrame(later), isTrue);
    });

    test('markProcessingFailed can skip dropped-frame increment', () {
      controller.markProcessingStarted();
      controller.markProcessingFailed(countAsDropped: false);
      expect(controller.isProcessing, isFalse);
      expect(controller.diagnostics().droppedFrames, 0);
      expect(controller.diagnostics().processedFrames, 0);
    });

    test('shouldProcessFrame works after markProcessingFailed once FPS allows',
        () {
      final high = FrameProcessingController(
        config: PerformanceConfig.highPerformance(),
      );
      final t = DateTime(2026, 1, 1, 12);
      expect(high.shouldProcessFrame(t), isTrue);
      high.markProcessingStarted();
      high.markProcessingFailed();

      // No successful completion → _lastProcessedAt stays null, so next accept
      // is not FPS-gated by a prior success.
      expect(high.shouldProcessFrame(t.add(const Duration(milliseconds: 1))),
          isTrue);
    });
  });
}

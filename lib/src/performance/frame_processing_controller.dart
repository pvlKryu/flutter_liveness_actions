import '../config/performance_config.dart';
import '../models/liveness_diagnostics.dart';

/// frame processing controller.
class FrameProcessingController {
  /// Creates a controller with the given performance [config].
  FrameProcessingController({required this.config});

  /// config.
  final PerformanceConfig config;
  bool _isProcessing = false;
  int _processedFrames = 0;
  int _droppedFrames = 0;
  int _frameCounter = 0;
  double _avgProcessingMs = 0;
  DateTime? _lastProcessedAt;

  /// should process frame.
  bool shouldProcessFrame(DateTime timestamp) {
    _frameCounter += 1;
    if (_isProcessing) {
      _droppedFrames += 1;
      return false;
    }
    if (config.frameSkipRatio > 0 &&
        _frameCounter % (config.frameSkipRatio + 1) != 1) {
      _droppedFrames += 1;
      return false;
    }
    if (_lastProcessedAt != null) {
      final minIntervalMs = (1000 / config.targetProcessingFps).round();
      if (timestamp.difference(_lastProcessedAt!).inMilliseconds <
          minIntervalMs) {
        _droppedFrames += 1;
        return false;
      }
    }
    return true;
  }

  /// mark processing started.
  void markProcessingStarted() {
    _isProcessing = true;
  }

  /// mark processing completed.
  void markProcessingCompleted(Duration duration) {
    _isProcessing = false;
    _lastProcessedAt = DateTime.now();
    _processedFrames += 1;
    _avgProcessingMs = ((_avgProcessingMs * (_processedFrames - 1)) +
            duration.inMilliseconds) /
        _processedFrames;
  }

  /// mark frame dropped.
  void markFrameDropped() {
    _droppedFrames += 1;
  }

  /// Returns current processing diagnostics snapshot.
  LivenessDiagnostics diagnostics() => LivenessDiagnostics(
        averageProcessingMs: _avgProcessingMs,
        processedFrames: _processedFrames,
        droppedFrames: _droppedFrames,
        targetProcessingFps: config.targetProcessingFps,
        recommendedPerformanceProfile: config.profile,
      );
}

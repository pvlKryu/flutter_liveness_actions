import '../config/performance_config.dart';
import '../models/liveness_diagnostics.dart';

/// Throttles camera-frame analysis for mobile performance and diagnostics.
class FrameProcessingController {
  /// Creates a controller with the given performance [config].
  FrameProcessingController({required PerformanceConfig config})
      : _config = config;

  PerformanceConfig _config;
  bool _isProcessing = false;
  bool _paused = false;
  int _processedFrames = 0;
  int _droppedFrames = 0;
  int _frameCounter = 0;
  int _inFlight = 0;
  double _avgProcessingMs = 0;
  DateTime? _lastProcessedAt;

  /// Active performance configuration.
  PerformanceConfig get config => _config;

  /// Whether processing is paused (for app lifecycle).
  bool get isPaused => _paused;

  /// Whether a frame is currently being processed.
  bool get isProcessing => _isProcessing;

  /// Replaces the active performance configuration.
  void updateConfig(PerformanceConfig config) {
    _config = config;
  }

  /// Pauses frame acceptance (e.g. app backgrounded).
  void pause() {
    _paused = true;
  }

  /// Resumes frame acceptance.
  void resume() {
    _paused = false;
  }

  /// Resets counters and busy state.
  void reset() {
    _isProcessing = false;
    _inFlight = 0;
    _processedFrames = 0;
    _droppedFrames = 0;
    _frameCounter = 0;
    _avgProcessingMs = 0;
    _lastProcessedAt = null;
  }

  /// Returns whether [timestamp] should be analyzed.
  bool shouldProcessFrame(DateTime timestamp) {
    _frameCounter += 1;
    if (_paused) {
      _droppedFrames += 1;
      return false;
    }
    if (_isProcessing || _inFlight >= _config.maxInFlightFrames) {
      _droppedFrames += 1;
      return false;
    }
    if (_config.frameSkipRatio > 0 &&
        _frameCounter % (_config.frameSkipRatio + 1) != 1) {
      _droppedFrames += 1;
      return false;
    }
    if (_lastProcessedAt != null) {
      final minIntervalMs = (1000 / _config.targetProcessingFps).round();
      if (timestamp.difference(_lastProcessedAt!).inMilliseconds <
          minIntervalMs) {
        _droppedFrames += 1;
        return false;
      }
    }
    return true;
  }

  /// Marks that frame analysis has started.
  void markProcessingStarted() {
    _isProcessing = true;
    _inFlight += 1;
  }

  /// Releases busy state after a failed analysis attempt.
  ///
  /// Call this when [markProcessingStarted] was already invoked but the frame
  /// could not be completed (unsupported format, conversion failure, detector
  /// error). Failed frames are counted as drops by default and are **not**
  /// counted as successfully processed.
  void markProcessingFailed({bool countAsDropped = true}) {
    _isProcessing = false;
    if (_inFlight > 0) {
      _inFlight -= 1;
    }
    if (countAsDropped) {
      _droppedFrames += 1;
    }
  }

  /// Marks that frame analysis completed in [duration].
  ///
  /// [processedAt] should match the accepted frame timestamp when available so
  /// FPS throttling stays correct for synthetic / replayed timestamps.
  void markProcessingCompleted(
    Duration duration, {
    DateTime? processedAt,
  }) {
    _isProcessing = false;
    if (_inFlight > 0) {
      _inFlight -= 1;
    }
    _lastProcessedAt = processedAt ?? DateTime.now();
    _processedFrames += 1;
    _avgProcessingMs = ((_avgProcessingMs * (_processedFrames - 1)) +
            duration.inMilliseconds) /
        _processedFrames;
  }

  /// Marks an explicit frame drop without changing busy/in-flight state.
  ///
  /// Prefer [markProcessingFailed] when [markProcessingStarted] has already
  /// been called for the current frame.
  void markFrameDropped() {
    _droppedFrames += 1;
  }

  /// Returns current processing diagnostics snapshot.
  LivenessDiagnostics diagnostics() => LivenessDiagnostics(
        averageProcessingMs: _avgProcessingMs,
        processedFrames: _processedFrames,
        droppedFrames: _droppedFrames,
        targetProcessingFps: _config.targetProcessingFps,
        recommendedPerformanceProfile: _config.profile,
      );
}

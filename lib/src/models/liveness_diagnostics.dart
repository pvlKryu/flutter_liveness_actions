import 'package:equatable/equatable.dart';

import '../performance/performance_profile.dart';

/// liveness diagnostics.
class LivenessDiagnostics extends Equatable {
  /// Creates an instance with optional overrides.
  const LivenessDiagnostics({
    this.averageProcessingMs = 0,
    this.processedFrames = 0,
    this.droppedFrames = 0,
    this.targetProcessingFps = 0,
    this.recommendedPerformanceProfile = PerformanceProfile.balanced,
  });

  /// average processing ms.
  final double averageProcessingMs;

  /// processed frames.
  final int processedFrames;

  /// dropped frames.
  final int droppedFrames;

  /// target processing fps.
  final int targetProcessingFps;

  /// recommended performance profile.
  final PerformanceProfile recommendedPerformanceProfile;

  /// Serializes diagnostics for audit events and debug screens.
  Map<String, Object?> toJson() => <String, Object?>{
        'averageProcessingMs': averageProcessingMs,
        'processedFrames': processedFrames,
        'droppedFrames': droppedFrames,
        'targetProcessingFps': targetProcessingFps,
        'recommendedPerformanceProfile': recommendedPerformanceProfile.name,
      };

  @override

  /// props.
  List<Object?> get props => [
        averageProcessingMs,
        processedFrames,
        droppedFrames,
        targetProcessingFps,
        recommendedPerformanceProfile,
      ];
}

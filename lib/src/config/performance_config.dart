import 'dart:ui';

import '../performance/performance_profile.dart';

/// Frame processing and analysis performance settings.
class PerformanceConfig {
  /// Creates a performance configuration.
  const PerformanceConfig({
    required this.profile,
    required this.targetProcessingFps,
    required this.maxInFlightFrames,
    required this.frameSkipRatio,
    required this.maxRollingBufferSize,
    required this.enableExtendedQualityChecks,
    required this.enableDiagnostics,
    this.recommendedCameraResolution,
  });

  /// Selected named performance profile.
  final PerformanceProfile profile;

  /// Target analysis frames per second.
  final int targetProcessingFps;

  /// Maximum concurrently processed frames (v0.2 keeps this at 1).
  final int maxInFlightFrames;

  /// Process 1 of every (ratio + 1) frames.
  final int frameSkipRatio;

  /// Rolling signal buffer size recommendation.
  final int maxRollingBufferSize;

  /// Whether heuristic extended quality checks may run.
  final bool enableExtendedQualityChecks;

  /// Whether diagnostics should be collected.
  final bool enableDiagnostics;

  /// Suggested camera / analysis resolution.
  final Size? recommendedCameraResolution;

  /// Creates a high-throughput performance profile.
  factory PerformanceConfig.highPerformance() => const PerformanceConfig(
        profile: PerformanceProfile.highPerformance,
        targetProcessingFps: 20,
        maxInFlightFrames: 1,
        frameSkipRatio: 0,
        maxRollingBufferSize: 16,
        enableExtendedQualityChecks: true,
        enableDiagnostics: true,
        recommendedCameraResolution: Size(1280, 720),
      );

  /// Creates a balanced default performance profile.
  factory PerformanceConfig.balanced() => const PerformanceConfig(
        profile: PerformanceProfile.balanced,
        targetProcessingFps: 12,
        maxInFlightFrames: 1,
        frameSkipRatio: 1,
        maxRollingBufferSize: 12,
        enableExtendedQualityChecks: true,
        enableDiagnostics: true,
        recommendedCameraResolution: Size(960, 540),
      );

  /// Creates a profile tuned for lower-end Android devices.
  factory PerformanceConfig.lowEndDevice() => const PerformanceConfig(
        profile: PerformanceProfile.lowEndDevice,
        targetProcessingFps: 8,
        maxInFlightFrames: 1,
        frameSkipRatio: 2,
        maxRollingBufferSize: 6,
        enableExtendedQualityChecks: false,
        enableDiagnostics: true,
        recommendedCameraResolution: Size(640, 480),
      );

  /// Creates a battery-saving performance profile.
  factory PerformanceConfig.batterySaver() => const PerformanceConfig(
        profile: PerformanceProfile.batterySaver,
        targetProcessingFps: 6,
        maxInFlightFrames: 1,
        frameSkipRatio: 3,
        maxRollingBufferSize: 6,
        enableExtendedQualityChecks: false,
        enableDiagnostics: true,
        recommendedCameraResolution: Size(640, 480),
      );

  /// Resolves a preset [PerformanceConfig] for [profile].
  factory PerformanceConfig.fromProfile(PerformanceProfile profile) {
    switch (profile) {
      case PerformanceProfile.highPerformance:
        return PerformanceConfig.highPerformance();
      case PerformanceProfile.balanced:
        return PerformanceConfig.balanced();
      case PerformanceProfile.lowEndDevice:
        return PerformanceConfig.lowEndDevice();
      case PerformanceProfile.batterySaver:
        return PerformanceConfig.batterySaver();
    }
  }

  /// Returns a copy with selectively overridden fields.
  PerformanceConfig copyWith({
    PerformanceProfile? profile,
    int? targetProcessingFps,
    int? maxInFlightFrames,
    int? frameSkipRatio,
    int? maxRollingBufferSize,
    bool? enableExtendedQualityChecks,
    bool? enableDiagnostics,
    Size? recommendedCameraResolution,
  }) {
    return PerformanceConfig(
      profile: profile ?? this.profile,
      targetProcessingFps: targetProcessingFps ?? this.targetProcessingFps,
      maxInFlightFrames: maxInFlightFrames ?? this.maxInFlightFrames,
      frameSkipRatio: frameSkipRatio ?? this.frameSkipRatio,
      maxRollingBufferSize: maxRollingBufferSize ?? this.maxRollingBufferSize,
      enableExtendedQualityChecks:
          enableExtendedQualityChecks ?? this.enableExtendedQualityChecks,
      enableDiagnostics: enableDiagnostics ?? this.enableDiagnostics,
      recommendedCameraResolution:
          recommendedCameraResolution ?? this.recommendedCameraResolution,
    );
  }
}

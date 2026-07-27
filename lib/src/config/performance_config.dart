import 'dart:ui';

import '../performance/performance_profile.dart';

/// performance config.
class PerformanceConfig {
  /// Creates an instance with optional overrides.
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

  /// profile.
  final PerformanceProfile profile;

  /// target processing fps.
  final int targetProcessingFps;

  /// max in flight frames.
  final int maxInFlightFrames;

  /// frame skip ratio.
  final int frameSkipRatio;

  /// max rolling buffer size.
  final int maxRollingBufferSize;

  /// enable extended quality checks.
  final bool enableExtendedQualityChecks;

  /// enable diagnostics.
  final bool enableDiagnostics;

  /// recommended camera resolution.
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
}

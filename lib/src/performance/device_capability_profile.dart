import 'dart:ui';

import '../models/liveness_diagnostics.dart';
import 'performance_profile.dart';

/// Heuristic device capability recommendation from runtime measurements.
///
/// This is not deep hardware fingerprinting. Use it only to recommend safer
/// processing settings for a wide range of Android/iOS devices.
class DeviceCapabilityProfile {
  /// Creates a capability profile recommendation.
  const DeviceCapabilityProfile({
    required this.recommendedProfile,
    required this.recommendedTargetFps,
    required this.averageProcessingLatency,
    required this.lowEndModeRecommended,
    this.platform,
    this.platformVersion,
    this.recommendedAnalysisResolution,
    this.dropRate = 0,
  });

  /// Recommended performance profile.
  final PerformanceProfile recommendedProfile;

  /// Recommended target processing FPS.
  final int recommendedTargetFps;

  /// Optional platform label (for diagnostics only).
  final String? platform;

  /// Optional platform version label.
  final String? platformVersion;

  /// Recommended analysis resolution.
  final Size? recommendedAnalysisResolution;

  /// Observed average processing latency.
  final Duration averageProcessingLatency;

  /// Whether a low-end / conservative mode is recommended.
  final bool lowEndModeRecommended;

  /// Fraction of dropped frames in `[0, 1]`.
  final double dropRate;

  /// Recommends a profile from runtime [diagnostics] measurements.
  factory DeviceCapabilityProfile.fromDiagnostics(
    LivenessDiagnostics diagnostics, {
    String? platform,
    String? platformVersion,
  }) {
    final total = diagnostics.processedFrames + diagnostics.droppedFrames;
    final dropRate =
        total == 0 ? 0.0 : diagnostics.droppedFrames / total.toDouble();
    final avgMs = diagnostics.averageProcessingMs;

    final PerformanceProfile resolved;
    if (avgMs >= 160 || dropRate >= 0.55) {
      resolved = PerformanceProfile.batterySaver;
    } else if (avgMs >= 110 || dropRate >= 0.35) {
      resolved = PerformanceProfile.lowEndDevice;
    } else if (avgMs <= 35 &&
        dropRate <= 0.10 &&
        diagnostics.processedFrames >= 20) {
      resolved = PerformanceProfile.highPerformance;
    } else {
      resolved = PerformanceProfile.balanced;
    }

    final lowEnd = resolved == PerformanceProfile.lowEndDevice ||
        resolved == PerformanceProfile.batterySaver;

    return DeviceCapabilityProfile(
      recommendedProfile: resolved,
      recommendedTargetFps: fpsFor(resolved),
      averageProcessingLatency: Duration(milliseconds: avgMs.round()),
      lowEndModeRecommended: lowEnd,
      recommendedAnalysisResolution:
          lowEnd ? const Size(640, 480) : const Size(960, 540),
      dropRate: dropRate,
      platform: platform,
      platformVersion: platformVersion,
    );
  }

  /// Target FPS associated with [profile].
  static int fpsFor(PerformanceProfile profile) {
    switch (profile) {
      case PerformanceProfile.highPerformance:
        return 20;
      case PerformanceProfile.balanced:
        return 12;
      case PerformanceProfile.lowEndDevice:
        return 8;
      case PerformanceProfile.batterySaver:
        return 6;
    }
  }
}

import 'dart:ui';

import '../models/liveness_diagnostics.dart';
import 'performance_profile.dart';

/// device capability profile.
class DeviceCapabilityProfile {
  /// Creates an instance with optional overrides.
  const DeviceCapabilityProfile({
    required this.recommendedProfile,
    required this.recommendedTargetFps,
    required this.averageProcessingLatency,
    required this.lowEndModeRecommended,
    this.platform,
    this.platformVersion,
    this.recommendedAnalysisResolution,
  });

  /// recommended profile.
  final PerformanceProfile recommendedProfile;

  /// recommended target fps.
  final int recommendedTargetFps;

  /// platform.
  final String? platform;

  /// platform version.
  final String? platformVersion;

  /// recommended analysis resolution.
  final Size? recommendedAnalysisResolution;

  /// average processing latency.
  final Duration averageProcessingLatency;

  /// low end mode recommended.
  final bool lowEndModeRecommended;

  /// Recommends a profile from runtime [diagnostics] measurements.
  factory DeviceCapabilityProfile.fromDiagnostics(
      LivenessDiagnostics diagnostics) {
    final lowEnd = diagnostics.averageProcessingMs >= 110;
    return DeviceCapabilityProfile(
      recommendedProfile: lowEnd
          ? PerformanceProfile.lowEndDevice
          : PerformanceProfile.balanced,
      recommendedTargetFps: lowEnd ? 8 : 12,
      averageProcessingLatency:
          Duration(milliseconds: diagnostics.averageProcessingMs.round()),
      lowEndModeRecommended: lowEnd,
      recommendedAnalysisResolution:
          lowEnd ? const Size(640, 480) : const Size(960, 540),
    );
  }
}

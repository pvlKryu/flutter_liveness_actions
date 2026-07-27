import '../config/performance_config.dart';
import '../models/liveness_diagnostics.dart';
import 'device_capability_profile.dart';
import 'performance_profile.dart';

/// Observes processing diagnostics and adapts [PerformanceConfig] with hysteresis.
///
/// Prevents rapid profile flapping on lower-end Android devices by requiring
/// consecutive matching recommendations before applying a change.
class AdaptivePerformanceController {
  /// Creates an adaptive controller starting from [initialConfig].
  AdaptivePerformanceController({
    PerformanceConfig? initialConfig,
    this.confirmationSamples = 3,
  }) : _config = initialConfig ?? PerformanceConfig.balanced();

  /// How many consecutive matching recommendations are required to switch.
  final int confirmationSamples;

  PerformanceConfig _config;
  PerformanceProfile? _pendingProfile;
  int _pendingCount = 0;

  /// Current applied performance configuration.
  PerformanceConfig get config => _config;

  /// Current applied profile.
  PerformanceProfile get profile => _config.profile;

  /// Observes [diagnostics] and may update the active config.
  ///
  /// Returns `true` when the applied profile changed.
  bool observe(LivenessDiagnostics diagnostics) {
    final capability = DeviceCapabilityProfile.fromDiagnostics(diagnostics);
    final recommended = capability.recommendedProfile;

    if (recommended == _config.profile) {
      _pendingProfile = null;
      _pendingCount = 0;
      return false;
    }

    if (_pendingProfile == recommended) {
      _pendingCount += 1;
    } else {
      _pendingProfile = recommended;
      _pendingCount = 1;
    }

    if (_pendingCount < confirmationSamples) {
      return false;
    }

    _config = PerformanceConfig.fromProfile(recommended);
    _pendingProfile = null;
    _pendingCount = 0;
    return true;
  }

  /// Forces a specific [profile] immediately.
  void forceProfile(PerformanceProfile profile) {
    _config = PerformanceConfig.fromProfile(profile);
    _pendingProfile = null;
    _pendingCount = 0;
  }
}

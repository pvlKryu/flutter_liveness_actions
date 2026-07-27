import '../config/performance_config.dart';
import '../models/challenge_state.dart';
import '../models/face_action_result.dart';
import '../models/guidance_message.dart';
import '../models/liveness_diagnostics.dart';

/// Immutable view of one processed frame through [LivenessActionSession].
class LivenessActionSnapshot {
  /// Creates a processing snapshot.
  const LivenessActionSnapshot({
    required this.result,
    required this.guidance,
    required this.diagnostics,
    required this.performanceConfig,
    required this.performanceProfileChanged,
    this.challengeState,
  });

  /// Analyzer output for the processed frame.
  final FaceActionResult result;

  /// Current challenge state, if challenge flow is enabled.
  final FaceChallengeState? challengeState;

  /// Composed UX guidance messages for this frame.
  final List<GuidanceMessage> guidance;

  /// Latest frame-processing diagnostics.
  final LivenessDiagnostics diagnostics;

  /// Active performance configuration after adaptive updates.
  final PerformanceConfig performanceConfig;

  /// Whether the adaptive controller changed profiles on this frame.
  final bool performanceProfileChanged;
}

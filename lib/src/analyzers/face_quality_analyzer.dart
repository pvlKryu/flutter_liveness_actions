import '../models/face_action_frame.dart';
import '../models/face_quality_result.dart';
import '../quality/face_quality_gate.dart';

/// face quality analyzer.
class FaceQualityAnalyzer {
  /// Creates an instance with optional overrides.
  const FaceQualityAnalyzer({required this.gate});

  /// gate.
  final FaceQualityGate gate;

  /// analyze.
  FaceQualityResult analyze(FaceActionFrame frame) => gate.evaluate(frame);
}

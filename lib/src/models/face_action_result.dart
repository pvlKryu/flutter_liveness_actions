import 'package:equatable/equatable.dart';

import 'face_action_frame.dart';
import 'face_action_signal.dart';
import 'face_quality_result.dart';
import 'liveness_diagnostics.dart';

/// face action result.
class FaceActionResult extends Equatable {
  /// Creates an instance with optional overrides.
  const FaceActionResult({
    required this.frame,
    required this.signal,
    required this.quality,
    required this.diagnostics,
    required this.processedAt,
  });

  /// frame.
  final FaceActionFrame frame;

  /// signal.
  final FaceActionSignal signal;

  /// quality.
  final FaceQualityResult quality;

  /// diagnostics.
  final LivenessDiagnostics diagnostics;

  /// processed at.
  final DateTime processedAt;

  @override

  /// props.
  List<Object?> get props => [frame, signal, quality, diagnostics, processedAt];
}

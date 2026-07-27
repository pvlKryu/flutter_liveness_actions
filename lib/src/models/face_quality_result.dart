import 'package:equatable/equatable.dart';

import '../quality/face_quality_warning.dart';
import 'face_quality_status.dart';
import 'guidance_message.dart';

/// Outcome of a face quality gate evaluation for a single frame.
class FaceQualityResult extends Equatable {
  /// Creates a quality result with [status], [isAcceptable], and optional guidance.
  const FaceQualityResult({
    required this.status,
    required this.isAcceptable,
    this.warnings = const <FaceQualityWarning>[],
    this.guidanceMessages = const <GuidanceMessage>[],
  });

  /// Derived quality classification for the current frame.
  final FaceQualityStatus status;

  /// Whether the frame passed all required quality checks.
  final bool isAcceptable;

  /// Non-blocking quality warnings (heuristic where noted in docs).
  final List<FaceQualityWarning> warnings;

  /// UX guidance messages derived from the quality state.
  final List<GuidanceMessage> guidanceMessages;

  @override

  /// props.
  List<Object?> get props => [status, isAcceptable, warnings, guidanceMessages];
}

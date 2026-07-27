import 'package:equatable/equatable.dart';

import '../guidance/guidance_code.dart';
import '../guidance/guidance_severity.dart';

/// guidance message.
class GuidanceMessage extends Equatable {
  /// Creates an instance with optional overrides.
  const GuidanceMessage({
    required this.code,
    required this.severity,
    required this.defaultEnglishText,
    this.canUseHapticFeedback = false,
    this.semanticLabel,
  });

  /// code.
  final GuidanceCode code;

  /// severity.
  final GuidanceSeverity severity;

  /// default english text.
  final String defaultEnglishText;

  /// can use haptic feedback.
  final bool canUseHapticFeedback;

  /// semantic label.
  final String? semanticLabel;

  @override

  /// props.
  List<Object?> get props => [
        code,
        severity,
        defaultEnglishText,
        canUseHapticFeedback,
        semanticLabel,
      ];
}

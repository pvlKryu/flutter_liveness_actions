import 'package:equatable/equatable.dart';

import '../guidance/guidance_code.dart';
import '../guidance/guidance_severity.dart';

/// Accessibility-friendly UX guidance derived from interaction signals.
class GuidanceMessage extends Equatable {
  /// Creates a guidance message with localization and accessibility metadata.
  const GuidanceMessage({
    required this.code,
    required this.messageKey,
    required this.severity,
    required this.defaultEnglishText,
    this.canUseHapticFeedback = false,
    this.semanticLabel,
    this.announceForAccessibility = false,
    this.highContrastLabel,
  });

  /// Stable guidance classification code.
  final GuidanceCode code;

  /// Localization key for apps (for example `guidance.move_closer`).
  final String messageKey;

  /// UX severity for prioritization and styling.
  final GuidanceSeverity severity;

  /// Default English fallback text for demos and prototypes.
  final String defaultEnglishText;

  /// Whether apps may trigger haptic feedback when showing this message.
  final bool canUseHapticFeedback;

  /// Screen reader label override.
  final String? semanticLabel;

  /// Whether assistive technologies should announce this message live.
  final bool announceForAccessibility;

  /// Short non-color-only label for high-contrast UI chips.
  final String? highContrastLabel;

  /// Resolves display text using an optional [localize] callback.
  String resolveText([String Function(String messageKey)? localize]) {
    if (localize == null) {
      return defaultEnglishText;
    }
    return localize(messageKey);
  }

  @override
  List<Object?> get props => [
        code,
        messageKey,
        severity,
        defaultEnglishText,
        canUseHapticFeedback,
        semanticLabel,
        announceForAccessibility,
        highContrastLabel,
      ];
}

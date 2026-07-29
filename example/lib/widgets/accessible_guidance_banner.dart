import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

/// Accessible guidance banner with semantics and optional haptic feedback.
class AccessibleGuidanceBanner extends StatefulWidget {
  /// Creates an accessible guidance banner.
  const AccessibleGuidanceBanner({
    super.key,
    required this.message,
    this.onLocalizedText,
  });

  /// Guidance message metadata to render.
  final GuidanceMessage message;

  /// Optional localization callback keyed by [GuidanceMessage.messageKey].
  final String Function(String messageKey)? onLocalizedText;

  @override
  State<AccessibleGuidanceBanner> createState() =>
      _AccessibleGuidanceBannerState();
}

class _AccessibleGuidanceBannerState extends State<AccessibleGuidanceBanner> {
  String? _lastAnnounced;

  @override
  void didUpdateWidget(covariant AccessibleGuidanceBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeAnnounce();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAnnounce());
  }

  void _maybeAnnounce() {
    if (!mounted) {
      return;
    }
    final text = widget.message.resolveText(widget.onLocalizedText);
    if (!widget.message.announceForAccessibility || _lastAnnounced == text) {
      return;
    }
    _lastAnnounced = text;
    if (widget.message.canUseHapticFeedback) {
      HapticFeedback.selectionClick();
    }
    if (MediaQuery.supportsAnnounceOf(context)) {
      SemanticsService.sendAnnouncement(
        View.of(context),
        text,
        TextDirection.ltr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.message.resolveText(widget.onLocalizedText);
    final chip = widget.message.highContrastLabel;

    return Semantics(
      label: widget.message.semanticLabel ?? text,
      liveRegion: widget.message.announceForAccessibility,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _backgroundFor(widget.message.severity, context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderFor(widget.message.severity)),
        ),
        child: Row(
          children: <Widget>[
            if (chip != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  chip,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            if (chip != null) const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        ),
      ),
    );
  }

  Color _backgroundFor(GuidanceSeverity severity, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    switch (severity) {
      case GuidanceSeverity.error:
        return isDark
            ? Colors.red.shade900.withValues(alpha: 0.3)
            : Colors.red.shade50;
      case GuidanceSeverity.warning:
        return isDark
            ? Colors.orange.shade900.withValues(alpha: 0.3)
            : Colors.orange.shade50;
      case GuidanceSeverity.success:
        return isDark
            ? Colors.green.shade900.withValues(alpha: 0.3)
            : Colors.green.shade50;
      case GuidanceSeverity.info:
        return Theme.of(context).colorScheme.surfaceContainerHighest;
    }
  }

  Color _borderFor(GuidanceSeverity severity) {
    switch (severity) {
      case GuidanceSeverity.error:
        return Colors.red.shade300;
      case GuidanceSeverity.warning:
        return Colors.orange.shade300;
      case GuidanceSeverity.success:
        return Colors.green.shade300;
      case GuidanceSeverity.info:
        return Colors.blueGrey.shade300;
    }
  }
}

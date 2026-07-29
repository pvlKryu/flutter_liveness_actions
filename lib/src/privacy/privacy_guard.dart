import '../config/privacy_config.dart';

/// privacy guard.
class PrivacyGuard {
  /// Creates an instance with optional overrides.
  const PrivacyGuard({this.config = const PrivacyConfig()});

  /// config.
  final PrivacyConfig config;

  /// Builds immutable privacy flags for inclusion in audit events.
  ///
  /// Package guarantee embedded in every audit JSON (when enabled):
  /// `{ "derivedSignalsOnly": true, "rawImagesStored": false }`.
  /// Host [PrivacyConfig] cannot weaken these flags in audit output.
  Map<String, Object?> auditPrivacyFlags() {
    if (!config.includePrivacyFlagsInAuditEvent) {
      return const <String, Object?>{};
    }
    return const <String, Object?>{
      'derivedSignalsOnly': true,
      'rawImagesStored': false,
      'rawImagesUploaded': false,
    };
  }
}

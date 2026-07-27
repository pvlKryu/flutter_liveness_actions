import '../config/privacy_config.dart';

/// privacy guard.
class PrivacyGuard {
  /// Creates an instance with optional overrides.
  const PrivacyGuard({this.config = const PrivacyConfig()});

  /// config.
  final PrivacyConfig config;

  /// Builds privacy flags for inclusion in audit events.
  Map<String, Object?> auditPrivacyFlags() => <String, Object?>{
        'rawImagesStored': config.allowRawImageStorage,
        'rawImagesUploaded': config.allowRawImageUpload,
        'derivedSignalsOnly': config.derivedSignalsOnly,
      };
}

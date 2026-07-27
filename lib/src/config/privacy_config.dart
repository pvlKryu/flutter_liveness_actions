/// privacy config.
class PrivacyConfig {
  /// Creates an instance with optional overrides.
  const PrivacyConfig({
    this.allowRawImageStorage = false,
    this.allowRawImageUpload = false,
    this.derivedSignalsOnly = true,
    this.includePrivacyFlagsInAuditEvent = true,
  });

  /// allow raw image storage.
  final bool allowRawImageStorage;

  /// allow raw image upload.
  final bool allowRawImageUpload;

  /// derived signals only.
  final bool derivedSignalsOnly;

  /// include privacy flags in audit event.
  final bool includePrivacyFlagsInAuditEvent;
}

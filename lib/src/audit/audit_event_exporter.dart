import 'dart:convert';

import '../models/onboarding_audit_event.dart';

/// audit event exporter.
class AuditEventExporter {
  /// Creates an instance with optional overrides.
  const AuditEventExporter();

  /// to pretty json.
  String toPrettyJson(OnboardingAuditEvent event) {
    return const JsonEncoder.withIndent('  ').convert(event.toJson());
  }
}

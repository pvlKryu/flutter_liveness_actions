import 'package:equatable/equatable.dart';

import '../audit/audit_event_builder.dart';
import '../challenge/challenge_flow_controller.dart';
import '../models/face_action_frame.dart';
import 'security_violation_code.dart';

/// Immutable result of a [MultiFaceSecurityGate] evaluation.
class MultiFaceSecurityResult extends Equatable {
  /// Creates a security-gate result.
  const MultiFaceSecurityResult({
    required this.violated,
    required this.faceCount,
    required this.timestamp,
    this.violationCode,
  });

  /// Whether a security fail-safe should fire.
  final bool violated;

  /// Face count that was evaluated (typically `faces.length` from ML Kit).
  final int faceCount;

  /// Evaluation timestamp.
  final DateTime timestamp;

  /// Violation code when [violated] is true.
  final SecurityViolationCode? violationCode;

  /// JSON-compatible metadata for audit trail entries.
  Map<String, Object?> toAuditMetadata() => <String, Object?>{
        'securityViolation': violationCode?.name,
        'faceCount': faceCount,
        'violated': violated,
      };

  @override
  List<Object?> get props => [violated, faceCount, timestamp, violationCode];
}

/// Fail-safe gate that locks challenge flow when multiple faces appear.
///
/// The package never retains ML Kit `Face` objects or image bytes. Host apps
/// pass `faces.length` (or [FaceActionFrame.faceCount]) into [evaluate].
///
/// On violation this gate:
/// 1. Marks the result with [SecurityViolationCode.multiFaceDetected]
/// 2. Optionally locks [ChallengeFlowController] into a compromised state
/// 3. Optionally records a privacy-safe audit trail entry
class MultiFaceSecurityGate {
  /// Creates a multi-face security gate.
  ///
  /// When [failOnMultipleFaces] is false, evaluations never violate (useful
  /// for demos that only surface guidance).
  const MultiFaceSecurityGate({this.failOnMultipleFaces = true});

  /// Whether `faceCount > 1` is treated as a security violation.
  final bool failOnMultipleFaces;

  /// Evaluates detector face count (e.g. ML Kit `faces.length`).
  MultiFaceSecurityResult evaluate({
    required int faceCount,
    DateTime? timestamp,
  }) {
    final now = timestamp ?? DateTime.now();
    final violated = failOnMultipleFaces && faceCount > 1;
    return MultiFaceSecurityResult(
      violated: violated,
      faceCount: faceCount,
      timestamp: now,
      violationCode:
          violated ? SecurityViolationCode.multiFaceDetected : null,
    );
  }

  /// Convenience over a normalized [FaceActionFrame].
  MultiFaceSecurityResult evaluateFrame(
    FaceActionFrame frame, {
    DateTime? timestamp,
  }) {
    return evaluate(
      faceCount: frame.faceCount,
      timestamp: timestamp ?? frame.timestamp,
    );
  }

  /// Evaluates [faceCount] and, on violation, locks [controller] and records
  /// an audit trail entry via [auditBuilder] when provided.
  ///
  /// Returns the evaluation result. When not violated, the challenge and
  /// audit trail are left unchanged.
  MultiFaceSecurityResult apply({
    required int faceCount,
    ChallengeFlowController? controller,
    AuditEventBuilder? auditBuilder,
    DateTime? timestamp,
  }) {
    final result = evaluate(faceCount: faceCount, timestamp: timestamp);
    if (!result.violated || result.violationCode == null) {
      return result;
    }

    controller?.lockForSecurityViolation(
      result.violationCode!,
      now: result.timestamp,
    );
    auditBuilder?.recordSecurityViolation(
      result.violationCode!,
      faceCount: result.faceCount,
      timestamp: result.timestamp,
    );
    return result;
  }

  /// Frame-based variant of [apply].
  MultiFaceSecurityResult applyFrame(
    FaceActionFrame frame, {
    ChallengeFlowController? controller,
    AuditEventBuilder? auditBuilder,
    DateTime? timestamp,
  }) {
    return apply(
      faceCount: frame.faceCount,
      controller: controller,
      auditBuilder: auditBuilder,
      timestamp: timestamp ?? frame.timestamp,
    );
  }
}

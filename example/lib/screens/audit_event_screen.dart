import 'package:flutter/material.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

/// Displays a privacy-safe audit event JSON payload.
class AuditEventScreen extends StatelessWidget {
  /// Creates the audit event screen.
  const AuditEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final OnboardingAuditEvent event;
    if (args is OnboardingAuditEvent) {
      event = args;
    } else if (args is AuditEventBuilder) {
      event = args.build(
        challengeState: FaceChallengeState.initial(
          DefaultChallenges.defaultSequence().steps,
        ),
        faceDetected: true,
        multipleFacesDetected: false,
        diagnostics: const LivenessDiagnostics(
          averageProcessingMs: 42,
          processedFrames: 120,
          droppedFrames: 8,
          targetProcessingFps: 12,
        ),
        completedAt: DateTime.now(),
      );
    } else {
      final builder =
          AuditEventBuilder(
              sessionId: 'demo-session-123',
              sequenceId: DefaultChallenges.defaultSequence().sequenceId,
              packageVersion: packageVersion,
              challengeNonce: 'optional-demo-nonce',
            )
            ..recordCameraReady()
            ..recordQualityGatePassed();
      event = builder.build(
        challengeState: FaceChallengeState.initial(
          DefaultChallenges.defaultSequence().steps,
        ),
        faceDetected: true,
        multipleFacesDetected: false,
        diagnostics: const LivenessDiagnostics(
          averageProcessingMs: 42,
          processedFrames: 120,
          droppedFrames: 8,
          targetProcessingFps: 12,
        ),
        completedAt: DateTime.now(),
      );
    }

    final json = const AuditEventExporter().toPrettyJson(event);

    return Scaffold(
      appBar: AppBar(title: const Text('Audit Event')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText(
            json,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          ),
        ),
      ),
    );
  }
}

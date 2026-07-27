import 'package:flutter/material.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

class AuditEventScreen extends StatelessWidget {
  const AuditEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final passedBuilder =
        ModalRoute.of(context)?.settings.arguments as AuditEventBuilder?;
    final builder = passedBuilder ??
        AuditEventBuilder(
          sessionId: 'demo-session-123',
          sequenceId: DefaultChallenges.defaultSequence().sequenceId,
          packageVersion: '0.3.0',
          challengeNonce: 'optional-demo-nonce',
        );

    if (passedBuilder == null) {
      builder.recordCameraReady();
      builder.recordQualityGatePassed();
    }

    final event = builder.build(
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

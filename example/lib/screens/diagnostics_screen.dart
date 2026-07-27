import 'package:flutter/material.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

class DiagnosticsScreen extends StatelessWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = FrameProcessingController(
      config: PerformanceConfig.balanced(),
    );
    controller.markProcessingStarted();
    controller.markProcessingCompleted(const Duration(milliseconds: 38));
    final diagnostics = controller.diagnostics();
    final capability = DeviceCapabilityProfile.fromDiagnostics(diagnostics);

    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _row('averageProcessingMs', diagnostics.averageProcessingMs),
          _row('processedFrames', diagnostics.processedFrames),
          _row('droppedFrames', diagnostics.droppedFrames),
          _row('targetProcessingFps', diagnostics.targetProcessingFps),
          _row(
            'recommendedPerformanceProfile',
            capability.recommendedProfile.name,
          ),
          _row('lowEndModeRecommended', capability.lowEndModeRecommended),
        ],
      ),
    );
  }

  Widget _row(String label, Object value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          Chip(label: Text('$value')),
        ],
      ),
    );
  }
}

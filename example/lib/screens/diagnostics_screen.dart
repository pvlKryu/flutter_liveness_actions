import 'package:flutter/material.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

/// Live diagnostics for frame processing and adaptive performance.
class DiagnosticsScreen extends StatefulWidget {
  /// Creates the diagnostics screen.
  const DiagnosticsScreen({super.key});

  @override
  State<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends State<DiagnosticsScreen> {
  late final AdaptivePerformanceController _adaptive;
  late final FrameProcessingController _controller;
  late LivenessDiagnostics _diagnostics;
  late DeviceCapabilityProfile _capability;
  bool _ready = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) {
      return;
    }
    _ready = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is LivenessDiagnostics) {
      _diagnostics = args;
      _capability = DeviceCapabilityProfile.fromDiagnostics(_diagnostics);
      _adaptive = AdaptivePerformanceController(
        initialConfig: PerformanceConfig.balanced(),
      );
      _controller = FrameProcessingController(config: _adaptive.config);
      return;
    }
    _adaptive = AdaptivePerformanceController();
    _controller = FrameProcessingController(config: _adaptive.config);
    for (var i = 0; i < 24; i++) {
      final ts = DateTime(2026, 1, 1).add(Duration(milliseconds: i * 80));
      if (_controller.shouldProcessFrame(ts)) {
        _controller.markProcessingStarted();
        _controller.markProcessingCompleted(
          Duration(milliseconds: 40 + (i % 5) * 15),
        );
      }
    }
    _adaptive.observe(_controller.diagnostics());
    _controller.updateConfig(_adaptive.config);
    _diagnostics = _controller.diagnostics();
    _capability = DeviceCapabilityProfile.fromDiagnostics(_diagnostics);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Diagnostics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _row(
            'averageProcessingMs',
            _diagnostics.averageProcessingMs.toStringAsFixed(1),
          ),
          _row('processedFrames', _diagnostics.processedFrames),
          _row('droppedFrames', _diagnostics.droppedFrames),
          _row('targetProcessingFps', _diagnostics.targetProcessingFps),
          _row('activeProfile', _adaptive.profile.name),
          _row(
            'recommendedPerformanceProfile',
            _capability.recommendedProfile.name,
          ),
          _row('lowEndModeRecommended', _capability.lowEndModeRecommended),
          _row(
            'dropRate',
            '${(_capability.dropRate * 100).toStringAsFixed(1)}%',
          ),
          _row(
            'recommendedAnalysisResolution',
            _capability.recommendedAnalysisResolution == null
                ? '-'
                : '${_capability.recommendedAnalysisResolution!.width.toInt()}x'
                      '${_capability.recommendedAnalysisResolution!.height.toInt()}',
          ),
          const SizedBox(height: 16),
          const Text(
            'Optimized for a wide range of Android devices, including lower-end '
            'phones, subject to platform and camera plugin limitations.',
          ),
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

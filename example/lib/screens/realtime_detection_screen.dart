import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../services/camera_liveness_session.dart';

/// Real-time face detection with live config tuning panel.
class RealtimeDetectionScreen extends StatefulWidget {
  const RealtimeDetectionScreen({super.key});

  @override
  State<RealtimeDetectionScreen> createState() =>
      _RealtimeDetectionScreenState();
}

class _RealtimeDetectionScreenState extends State<RealtimeDetectionScreen>
    with WidgetsBindingObserver {
  CameraLivenessSession? _session;
  PerformanceProfile _profile = PerformanceProfile.balanced;
  bool _showPanel = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startSession();
  }

  void _startSession() {
    _session?.removeListener(_onUpdate);
    _session?.close();
    _session = CameraLivenessSession(
      initialConfig: PerformanceConfig.fromProfile(_profile),
    );
    _session!.addListener(_onUpdate);
    _session!.initialize();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _session?.handleAppLifecycle(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _session?.removeListener(_onUpdate);
    _session?.close();
    super.dispose();
  }

  void _switchProfile(PerformanceProfile p) {
    if (p == _profile) return;
    setState(() => _profile = p);
    _startSession();
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    final result = session?.latestResult;
    final signal = result?.signal;
    final frame = result?.frame;
    final diag = session?.diagnostics;
    final config = session?.performanceConfig;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'Real-time detection',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _showPanel ? Icons.tune : Icons.tune_outlined,
                      color: _showPanel ? Colors.greenAccent : Colors.white70,
                    ),
                    onPressed: () => setState(() => _showPanel = !_showPanel),
                  ),
                ],
              ),
            ),

            // Camera
            Expanded(
              flex: _showPanel ? 4 : 6,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      const ColoredBox(color: Colors.black12),
                      if (session != null && session.isReady)
                        CameraPreview(session.cameraController!)
                      else if (session != null && session.isInitializing)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white70,
                          ),
                        )
                      else
                        Center(
                          child: Text(
                            session?.error ?? 'Initializing...',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      // Real-time HUD
                      if (frame != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: _HudOverlay(frame: frame, signal: signal),
                        ),
                      // FPS badge
                      if (diag != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${diag.averageProcessingMs.toStringAsFixed(0)} ms  '
                              '${diag.processedFrames} frames',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontFamily: 'monospace',
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Signal bar
            if (signal != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: _SignalBar(signal: signal),
              ),

            // Settings panel
            if (_showPanel)
              Expanded(
                flex: 3,
                child: _SettingsPanel(
                  profile: _profile,
                  config: config,
                  onProfileChanged: _switchProfile,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HudOverlay extends StatelessWidget {
  const _HudOverlay({required this.frame, this.signal});
  final FaceActionFrame frame;
  final FaceActionSignal? signal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.greenAccent,
          fontFamily: 'monospace',
          fontSize: 10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'L eye: ${frame.leftEyeOpenProbability?.toStringAsFixed(3) ?? '---'}',
            ),
            Text(
              'R eye: ${frame.rightEyeOpenProbability?.toStringAsFixed(3) ?? '---'}',
            ),
            Text(
              'Smile: ${frame.smilingProbability?.toStringAsFixed(3) ?? '---'}',
            ),
            Text(
              'Yaw:   ${frame.headEulerAngleY?.toStringAsFixed(1) ?? '---'}°',
            ),
            Text(
              'Pitch: ${frame.headEulerAngleX?.toStringAsFixed(1) ?? '---'}°',
            ),
            Text(
              'Roll:  ${frame.headEulerAngleZ?.toStringAsFixed(1) ?? '---'}°',
            ),
            Text('Faces: ${frame.faceCount}'),
            if (signal != null) ...[
              const Divider(color: Colors.white24, height: 8),
              _signalLine('blink', signal!.blinkDetected),
              _signalLine('centered', signal!.faceCentered),
              _signalLine('still', signal!.holdStill),
            ],
          ],
        ),
      ),
    );
  }

  Widget _signalLine(String name, bool active) {
    return Text(
      '$name: ${active ? "■" : "□"}',
      style: TextStyle(color: active ? Colors.greenAccent : Colors.white38),
    );
  }
}

class _SignalBar extends StatelessWidget {
  const _SignalBar({required this.signal});
  final FaceActionSignal signal;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        _dot('Face', signal.faceDetected),
        _dot('Center', signal.faceCentered),
        _dot('Blink', signal.blinkDetected),
        _dot('Left', signal.headTurnedLeft),
        _dot('Right', signal.headTurnedRight),
        _dot('Still', signal.holdStill),
        _dot('Smile', signal.smileDetected),
      ],
    );
  }

  Widget _dot(String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? Colors.greenAccent : Colors.white12,
            border: Border.all(
              color: active ? Colors.greenAccent : Colors.white24,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white38,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  const _SettingsPanel({
    required this.profile,
    required this.config,
    required this.onProfileChanged,
  });

  final PerformanceProfile profile;
  final PerformanceConfig? config;
  final ValueChanged<PerformanceProfile> onProfileChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Performance profile',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PerformanceProfile.values.map((p) {
                final selected = p == profile;
                return GestureDetector(
                  onTap: () => onProfileChanged(p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.greenAccent.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected ? Colors.greenAccent : Colors.white12,
                      ),
                    ),
                    child: Text(
                      p.name,
                      style: TextStyle(
                        color: selected ? Colors.greenAccent : Colors.white60,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            if (config != null) ...[
              const Text(
                'Active config',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _configRow('Target FPS', '${config!.targetProcessingFps}'),
              _configRow('Frame skip', '${config!.frameSkipRatio}'),
              _configRow('Buffer size', '${config!.maxRollingBufferSize}'),
              _configRow(
                'Quality checks',
                config!.enableExtendedQualityChecks ? 'ON' : 'OFF',
              ),
              _configRow(
                'Resolution',
                config!.recommendedCameraResolution != null
                    ? '${config!.recommendedCameraResolution!.width.toInt()}×'
                          '${config!.recommendedCameraResolution!.height.toInt()}'
                    : '—',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _configRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

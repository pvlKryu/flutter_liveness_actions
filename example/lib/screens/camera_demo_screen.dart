import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../services/camera_liveness_session.dart';

/// Live camera preview with oval guide, signal chips, and debug overlay
/// showing raw ML Kit probabilities for troubleshooting.
class CameraDemoScreen extends StatefulWidget {
  const CameraDemoScreen({super.key});

  @override
  State<CameraDemoScreen> createState() => _CameraDemoScreenState();
}

class _CameraDemoScreenState extends State<CameraDemoScreen>
    with WidgetsBindingObserver {
  late final CameraLivenessSession _session;
  bool _showDebug = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = CameraLivenessSession(
      initialConfig: PerformanceConfig.balanced(),
    );
    _session.addListener(_onSessionUpdate);
    _session.initialize();
  }

  void _onSessionUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _session.handleAppLifecycle(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _session.removeListener(_onSessionUpdate);
    _session.close();
    super.dispose();
  }

  /// Releases the camera before opening Live Challenge so the next screen can
  /// own the front camera / ML Kit stream exclusively.
  Future<void> _startChallenge() async {
    _session.actionSession.pause();
    await _session.disposeCameraOnly();
    if (!mounted) return;
    await Navigator.pushNamed(context, '/live-challenge');
    if (!mounted) return;
    _session.actionSession.resume();
    await _session.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final result = _session.latestResult;
    final signal = result?.signal;
    final frame = result?.frame;
    final guidance = _session.guidanceMessages;

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
                    'Camera Demo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      _showDebug ? Icons.bug_report : Icons.bug_report_outlined,
                      color: _showDebug ? Colors.greenAccent : Colors.white70,
                    ),
                    onPressed: () => setState(() => _showDebug = !_showDebug),
                    tooltip: 'Toggle debug overlay',
                  ),
                ],
              ),
            ),

            // Camera
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      const ColoredBox(color: Colors.black12),
                      if (_session.isReady)
                        CameraPreview(_session.cameraController!)
                      else if (_session.isInitializing)
                        const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white70),
                        )
                      else
                        Center(
                          child: Text(
                            _session.error ?? 'Camera unavailable',
                            style: const TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      IgnorePointer(
                        child: CustomPaint(painter: _OvalGuidePainter()),
                      ),
                      // Debug overlay
                      if (_showDebug && frame != null)
                        Positioned(
                          top: 12,
                          left: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: DefaultTextStyle(
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontFamily: 'monospace',
                                fontSize: 11,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                      'L eye: ${frame.leftEyeOpenProbability?.toStringAsFixed(3) ?? 'null'}'),
                                  Text(
                                      'R eye: ${frame.rightEyeOpenProbability?.toStringAsFixed(3) ?? 'null'}'),
                                  Text(
                                      'Smile: ${frame.smilingProbability?.toStringAsFixed(3) ?? 'null'}'),
                                  Text(
                                      'Yaw: ${frame.headEulerAngleY?.toStringAsFixed(1) ?? 'null'}'),
                                  Text(
                                      'Pitch: ${frame.headEulerAngleX?.toStringAsFixed(1) ?? 'null'}'),
                                  Text('Faces: ${frame.faceCount}'),
                                  if (signal != null)
                                    Text(
                                        'Blink: ${signal.blinkDetected ? "YES" : "no"}'),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Signal chips
            if (signal != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _chip('face', signal.faceDetected),
                    _chip('centered', signal.faceCentered),
                    _chip('blink', signal.blinkDetected),
                    _chip('left', signal.headTurnedLeft),
                    _chip('right', signal.headTurnedRight),
                    _chip('still', signal.holdStill),
                  ],
                ),
              ),
            const SizedBox(height: 8),

            if (guidance.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  guidance.first.defaultEnglishText,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 8),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${_session.performanceConfig.profile.name} · '
                'avg ${_session.diagnostics.averageProcessingMs.toStringAsFixed(0)} ms',
                style: const TextStyle(color: Colors.white38, fontSize: 12),
              ),
            ),
            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: _startChallenge,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text('Start challenge'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/diagnostics'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Diag'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? Colors.greenAccent.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? Colors.greenAccent.withValues(alpha: 0.5)
              : Colors.white12,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? Colors.greenAccent : Colors.white38,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _OvalGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.62,
      height: size.height * 0.48,
    );
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

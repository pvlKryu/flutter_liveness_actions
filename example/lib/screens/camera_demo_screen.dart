import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../services/camera_liveness_session.dart';

/// Live camera preview with oval guide and derived guidance signals.
class CameraDemoScreen extends StatefulWidget {
  /// Creates the camera demo screen.
  const CameraDemoScreen({super.key});

  @override
  State<CameraDemoScreen> createState() => _CameraDemoScreenState();
}

class _CameraDemoScreenState extends State<CameraDemoScreen>
    with WidgetsBindingObserver {
  late final CameraLivenessSession _session;

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
    if (mounted) {
      setState(() {});
    }
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

  @override
  Widget build(BuildContext context) {
    final result = _session.latestResult;
    final signal = result?.signal;
    final guidance = _session.guidanceMessages;

    return Scaffold(
      appBar: AppBar(title: const Text('Camera Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ColoredBox(color: Colors.black12),
                    if (_session.isReady)
                      CameraPreview(_session.cameraController!)
                    else if (_session.isInitializing)
                      const Center(child: CircularProgressIndicator())
                    else
                      Center(
                        child: Text(
                          _session.error ?? 'Camera unavailable',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    IgnorePointer(
                      child: CustomPaint(painter: _OvalGuidePainter()),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (signal != null)
              Wrap(
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
            const SizedBox(height: 8),
            if (guidance.isNotEmpty)
              Text(
                guidance.first.defaultEnglishText,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 8),
            Text(
              'Profile: ${_session.performanceConfig.profile.name} · '
              'avg ${_session.diagnostics.averageProcessingMs.toStringAsFixed(0)} ms',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pushNamed(context, '/challenge'),
                    child: const Text('Open challenge'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/diagnostics'),
                    child: const Text('Diagnostics'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool active) {
    return Chip(
      label: Text(label),
      backgroundColor: active ? Colors.green.shade100 : null,
    );
  }
}

class _OvalGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white70
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

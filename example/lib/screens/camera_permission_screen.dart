import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

/// Requests camera permission before the live demo.
class CameraPermissionScreen extends StatefulWidget {
  /// Creates the camera permission screen.
  const CameraPermissionScreen({super.key});

  @override
  State<CameraPermissionScreen> createState() => _CameraPermissionScreenState();
}

class _CameraPermissionScreenState extends State<CameraPermissionScreen> {
  String? _message;
  bool _requesting = false;

  Future<void> _request() async {
    setState(() {
      _requesting = true;
      _message = null;
    });
    final status = await Permission.camera.request();
    if (!mounted) {
      return;
    }
    setState(() => _requesting = false);

    if (status.isGranted) {
      Navigator.pushNamed(context, '/camera');
      return;
    }

    final guidance = const GuidanceMessageBuilder().cameraPermissionRequired();
    setState(() {
      _message = status.isPermanentlyDenied
          ? '${guidance.defaultEnglishText} Open system settings to enable camera access.'
          : guidance.defaultEnglishText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Permission')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Camera access is used only for local, on-device face action '
              'signal processing. This example does not store or upload face images.',
            ),
            const SizedBox(height: 16),
            if (_message != null) ...<Widget>[
              Text(_message!, style: TextStyle(color: Colors.red.shade700)),
              const SizedBox(height: 12),
            ],
            FilledButton(
              onPressed: _requesting ? null : _request,
              child: Text(_requesting ? 'Requesting…' : 'Allow camera access'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Open settings'),
            ),
          ],
        ),
      ),
    );
  }
}

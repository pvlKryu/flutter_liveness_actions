import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

class CameraPermissionScreen extends StatefulWidget {
  const CameraPermissionScreen({super.key});

  @override
  State<CameraPermissionScreen> createState() => _CameraPermissionScreenState();
}

class _CameraPermissionScreenState extends State<CameraPermissionScreen>
    with SingleTickerProviderStateMixin {
  String? _message;
  bool _requesting = false;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _checkExistingPermission();
  }

  Future<void> _checkExistingPermission() async {
    final status = await Permission.camera.status;
    if (!mounted) return;
    if (status.isGranted) {
      Navigator.pushReplacementNamed(context, '/camera');
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _request() async {
    setState(() {
      _requesting = true;
      _message = null;
    });
    final status = await Permission.camera.request();
    if (!mounted) return;
    setState(() => _requesting = false);

    if (status.isGranted) {
      Navigator.pushReplacementNamed(context, '/camera');
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
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            children: <Widget>[
              const Spacer(flex: 2),
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) {
                  final scale = 1.0 + _pulse.value * 0.08;
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    size: 52,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Camera access',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Used only for local, on-device face signal processing.\n'
                'No images are stored or uploaded.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              if (_message != null)
                AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Text(
                      _message!,
                      style: TextStyle(color: Colors.red.shade700),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _requesting ? null : _request,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _requesting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Allow camera access',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => openAppSettings(),
                child: const Text('Open system settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../services/camera_liveness_session.dart';

/// Live "Follow the dot" challenge with smooth target motion and confetti finale.
class FollowDotScreen extends StatefulWidget {
  const FollowDotScreen({super.key});

  @override
  State<FollowDotScreen> createState() => _FollowDotScreenState();
}

class _FollowDotScreenState extends State<FollowDotScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final CameraLivenessSession _session;
  late final AnimationController _dotPulse;
  late final AnimationController _dotMove;
  late final AnimationController _confettiController;

  Offset _fromNorm = const Offset(0.5, 0.5);
  Offset _toNorm = const Offset(0.5, 0.5);
  String? _lastTargetId;
  bool _celebrating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = CameraLivenessSession(
      enableChallenge: true,
      sessionId: 'follow-dot',
      challengeConfig: const FaceChallengeConfig(
        sequenceIdPrefix: 'follow-dot',
        randomize: true,
        seed: 100,
        enableTargetPath: true,
        randomizeTargetPath: true,
        targetSeed: 77,
        maxTargetSteps: 6,
        allowedSteps: <FaceActionType>[
          FaceActionType.centerFace,
          FaceActionType.followTargetPath,
        ],
        maxSteps: 2,
      ),
      initialConfig: PerformanceConfig.balanced(),
    );
    _session.addListener(_onUpdate);
    _session.initialize();

    _dotPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _dotMove = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );
  }

  void _onUpdate() {
    if (!mounted) return;

    final completed = _session.challenge?.state.completed ?? false;
    if (completed && !_celebrating) {
      _celebrating = true;
      _confettiController.forward(from: 0);
    }

    final target = _session.challenge?.targetEvaluator?.currentTarget;
    if (target != null && target.id != _lastTargetId) {
      final t = Curves.easeInOutCubic.transform(_dotMove.value.clamp(0.0, 1.0));
      _fromNorm = Offset.lerp(_fromNorm, _toNorm, t) ?? _toNorm;
      _toNorm = Offset(target.centerX, target.centerY);
      _lastTargetId = target.id;
      _dotMove.forward(from: 0);
    }

    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _session.handleAppLifecycle(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _session.removeListener(_onUpdate);
    _session.close();
    _dotPulse.dispose();
    _dotMove.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _session.challenge;
    final state = challenge?.state;
    final currentStep = state?.currentStep;
    final completed = state?.completed ?? false;
    final targetState = challenge?.targetEvaluator?.state;
    final pathProgress = targetState?.progress ?? (completed ? 1.0 : 0.0);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    'Follow the dot',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            if (currentStep?.type == FaceActionType.followTargetPath ||
                completed)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pathProgress,
                    minHeight: 5,
                    backgroundColor: Colors.white12,
                    color: completed ? Colors.greenAccent : Colors.white70,
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      if (_session.isReady)
                        CameraPreview(_session.cameraController!)
                      else if (_session.isInitializing)
                        const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white70,
                          ),
                        )
                      else
                        Center(
                          child: Text(
                            _session.error ?? 'Camera unavailable',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      if (currentStep != null &&
                          currentStep.type == FaceActionType.followTargetPath &&
                          currentStep.targetZones != null &&
                          currentStep.targetZones!.isNotEmpty &&
                          !completed)
                        _SmoothTargetDot(
                          pulse: _dotPulse,
                          move: _dotMove,
                          from: _fromNorm,
                          to: _toNorm,
                          radius: currentStep.targetZones!.first.radius,
                        ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            completed
                                ? 'Nice work — path complete!'
                                : currentStep?.instruction ?? 'Preparing...',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      if (completed) ...<Widget>[
                        IgnorePointer(
                          child: AnimatedBuilder(
                            animation: _confettiController,
                            builder: (context, _) => CustomPaint(
                              painter: _ConfettiPainter(
                                progress: _confettiController.value,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: ScaleTransition(
                            scale: CurvedAnimation(
                              parent: _confettiController,
                              curve: const Interval(
                                0,
                                0.35,
                                curve: Curves.elasticOut,
                              ),
                            ),
                            child: Container(
                              width: 96,
                              height: 96,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                size: 56,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (completed)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/audit',
                      arguments: _session.actionSession.buildAuditEvent(
                        completedAt: DateTime.now(),
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('View audit event'),
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SmoothTargetDot extends StatelessWidget {
  const _SmoothTargetDot({
    required this.pulse,
    required this.move,
    required this.from,
    required this.to,
    required this.radius,
  });

  final AnimationController pulse;
  final AnimationController move;
  final Offset from;
  final Offset to;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[pulse, move]),
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final t =
                Curves.easeInOutCubic.transform(move.value.clamp(0.0, 1.0));
            final norm = Offset.lerp(from, to, t) ?? to;
            final x = norm.dx * constraints.maxWidth;
            final y = norm.dy * constraints.maxHeight;
            final baseRadius = radius * constraints.maxWidth * 0.5;
            final pulseScale = 1.0 + pulse.value * 0.3;

            // Trail dots along the motion path.
            final trail = <Widget>[];
            for (var i = 1; i <= 4; i++) {
              final trailT = (t - i * 0.08).clamp(0.0, 1.0);
              final trailNorm = Offset.lerp(from, to, trailT) ?? from;
              final tx = trailNorm.dx * constraints.maxWidth;
              final ty = trailNorm.dy * constraints.maxHeight;
              final alpha = 0.18 - i * 0.03;
              trail.add(
                Positioned(
                  left: tx - 5,
                  top: ty - 5,
                  width: 10,
                  height: 10,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent.withValues(alpha: alpha),
                    ),
                  ),
                ),
              );
            }

            return Stack(
              children: <Widget>[
                ...trail,
                Positioned(
                  left: x - baseRadius * pulseScale,
                  top: y - baseRadius * pulseScale,
                  width: baseRadius * 2 * pulseScale,
                  height: baseRadius * 2 * pulseScale,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent.withValues(alpha: 0.15),
                      border: Border.all(
                        color: Colors.greenAccent.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: x - 12,
                  top: y - 12,
                  width: 24,
                  height: 24,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.greenAccent,
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: Colors.greenAccent.withValues(alpha: 0.45),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.progress});

  final double progress;

  static final List<_Particle> _particles = () {
    final rng = math.Random(42);
    return List<_Particle>.generate(48, (i) {
      final angle = rng.nextDouble() * math.pi * 2;
      final speed = 0.35 + rng.nextDouble() * 0.65;
      return _Particle(
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed - 0.4,
        size: 4 + rng.nextDouble() * 6,
        color: _colors[i % _colors.length],
        spin: (rng.nextDouble() - 0.5) * 8,
        shape: i % 3,
      );
    });
  }();

  static const List<Color> _colors = <Color>[
    Color(0xFF69F0AE),
    Color(0xFFFFD54F),
    Color(0xFFFF8A65),
    Color(0xFF82B1FF),
    Color(0xFFEA80FC),
    Color(0xFFFFFFFF),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final origin = Offset(size.width / 2, size.height * 0.42);
    final gravity = 1.8 * progress * progress;
    final fade = (1.0 - progress).clamp(0.0, 1.0);

    for (final p in _particles) {
      final x = origin.dx + p.vx * progress * size.width * 0.55;
      final y = origin.dy +
          p.vy * progress * size.height * 0.55 +
          gravity * size.height * 0.35;
      final paint = Paint()..color = p.color.withValues(alpha: fade);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(p.spin * progress);
      switch (p.shape) {
        case 0:
          canvas.drawCircle(Offset.zero, p.size / 2, paint);
        case 1:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              height: p.size * 0.55,
            ),
            paint,
          );
        default:
          final path = Path()
            ..moveTo(0, -p.size / 2)
            ..lineTo(p.size / 2, p.size / 2)
            ..lineTo(-p.size / 2, p.size / 2)
            ..close();
          canvas.drawPath(path, paint);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}

class _Particle {
  const _Particle({
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
    required this.spin,
    required this.shape,
  });

  final double vx;
  final double vy;
  final double size;
  final Color color;
  final double spin;
  final int shape;
}

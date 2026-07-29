import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../services/camera_liveness_session.dart';
import '../widgets/accessible_guidance_banner.dart';

class LiveChallengeScreen extends StatefulWidget {
  const LiveChallengeScreen({super.key, this.randomized = false});

  final bool randomized;

  @override
  State<LiveChallengeScreen> createState() => _LiveChallengeScreenState();
}

class _LiveChallengeScreenState extends State<LiveChallengeScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late final CameraLivenessSession _session;
  late final AnimationController _successController;
  late final Animation<double> _successScale;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _session = CameraLivenessSession(
      enableChallenge: true,
      sessionId: 'live-${widget.randomized ? 'random' : 'default'}',
      challengeConfig: FaceChallengeConfig(
        randomize: widget.randomized,
        seed: widget.randomized ? 42 : null,
        sequenceIdPrefix: widget.randomized ? 'live-random' : 'live',
        maxSteps: 4,
      ),
      initialConfig: PerformanceConfig.highPerformance(),
    );
    _session.addListener(_onUpdate);
    _session.initialize();

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _successScale = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
  }

  void _onUpdate() {
    if (!mounted) return;
    final completed = _session.challenge?.state.completed ?? false;
    if (completed && !_showSuccess) {
      _showSuccess = true;
      _successController.forward();
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
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final challenge = _session.challenge;
    final state = challenge?.state;
    final guidance = _session.guidanceMessages;
    final completed = state?.completed ?? false;
    final progress = state?.progress ?? 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    widget.randomized ? 'Randomized' : 'Challenge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Diagnostics',
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/diagnostics',
                      arguments: _session.diagnostics,
                    ),
                    icon: const Icon(Icons.speed, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                builder: (context, value, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: Colors.white12,
                    color: completed ? Colors.greenAccent : Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Camera preview
            Expanded(
              flex: 5,
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
                            textAlign: TextAlign.center,
                          ),
                        ),
                      // Oval guide
                      IgnorePointer(
                        child: CustomPaint(
                          painter: _OvalGuidePainter(progress),
                        ),
                      ),
                      // Success overlay
                      if (completed)
                        ScaleTransition(
                          scale: _successScale,
                          child: Center(
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
                  ),
                ),
              ),
            ),

            // Bottom section
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (guidance.isNotEmpty)
                      AccessibleGuidanceBanner(message: guidance.first),
                    const SizedBox(height: 12),
                    if (challenge != null)
                      Expanded(
                        child: SingleChildScrollView(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: challenge.sequence.steps
                                .map((step) => _StepChip(step: step))
                                .toList(growable: false),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: AnimatedOpacity(
                        opacity: completed ? 1.0 : 0.4,
                        duration: const Duration(milliseconds: 300),
                        child: FilledButton(
                          onPressed: completed
                              ? () => Navigator.pushNamed(
                                  context,
                                  '/audit',
                                  arguments: _session.actionSession
                                      .buildAuditEvent(
                                        completedAt: DateTime.now(),
                                      ),
                                )
                              : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: completed
                                ? Colors.greenAccent
                                : theme.colorScheme.surfaceContainerHighest,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'View audit event',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({required this.step});
  final FaceChallengeStep step;

  @override
  Widget build(BuildContext context) {
    final passed = step.status == ChallengeStepStatus.passed;
    final inProgress = step.status == ChallengeStepStatus.inProgress;
    final failed = step.status == ChallengeStepStatus.failed;

    Color bg;
    Color fg;
    if (passed) {
      bg = Colors.greenAccent.withValues(alpha: 0.2);
      fg = Colors.greenAccent;
    } else if (inProgress) {
      bg = Colors.white12;
      fg = Colors.white;
    } else if (failed) {
      bg = Colors.redAccent.withValues(alpha: 0.15);
      fg = Colors.redAccent;
    } else {
      bg = Colors.white.withValues(alpha: 0.05);
      fg = Colors.white38;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: inProgress ? Border.all(color: Colors.white38) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (passed)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(Icons.check_circle, size: 16, color: fg),
            ),
          if (failed)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(Icons.cancel, size: 16, color: fg),
            ),
          Text(
            step.type.name,
            style: TextStyle(
              color: fg,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OvalGuidePainter extends CustomPainter {
  _OvalGuidePainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final color = progress >= 1.0
        ? Colors.greenAccent.withValues(alpha: 0.7)
        : Colors.white.withValues(alpha: 0.5);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 0.62,
      height: size.height * 0.52,
    );
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(_OvalGuidePainter old) => old.progress != progress;
}

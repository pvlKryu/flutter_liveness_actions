import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../services/camera_liveness_session.dart';
import '../widgets/accessible_guidance_banner.dart';

/// Live camera challenge flow using [LivenessActionSession] under the hood.
class LiveChallengeScreen extends StatefulWidget {
  /// Creates a live challenge screen.
  const LiveChallengeScreen({super.key, this.randomized = false});

  /// Whether to randomize the challenge sequence.
  final bool randomized;

  @override
  State<LiveChallengeScreen> createState() => _LiveChallengeScreenState();
}

class _LiveChallengeScreenState extends State<LiveChallengeScreen>
    with WidgetsBindingObserver {
  late final CameraLivenessSession _session;

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
      initialConfig: PerformanceConfig.balanced(),
    );
    _session.addListener(_onUpdate);
    _session.initialize();
  }

  void _onUpdate() {
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
    _session.removeListener(_onUpdate);
    _session.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final challenge = _session.challenge;
    final state = challenge?.state;
    final guidance = _session.guidanceMessages;
    final completed = state?.completed ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.randomized ? 'Live randomized challenge' : 'Live challenge',
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Diagnostics',
            onPressed: () => Navigator.pushNamed(
              context,
              '/diagnostics',
              arguments: _session.diagnostics,
            ),
            icon: const Icon(Icons.speed),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColoredBox(
                  color: Colors.black12,
                  child: _session.isReady
                      ? CameraPreview(_session.cameraController!)
                      : Center(
                          child: _session.isInitializing
                              ? const CircularProgressIndicator()
                              : Text(
                                  _session.error ?? 'Camera unavailable',
                                  textAlign: TextAlign.center,
                                ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (guidance.isNotEmpty)
              AccessibleGuidanceBanner(message: guidance.first),
            const SizedBox(height: 12),
            if (challenge != null) ...<Widget>[
              Text(
                'Sequence: ${challenge.sequence.sequenceId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: state?.progress ?? 0),
              const SizedBox(height: 8),
              Text(
                completed
                    ? 'Challenge completed (demo signals only)'
                    : 'Step: ${state?.currentStep?.instruction ?? '—'}',
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: challenge.sequence.steps
                    .map(
                      (step) => Chip(
                        label: Text('${step.type.name}: ${step.status.name}'),
                      ),
                    )
                    .toList(growable: false),
              ),
            ],
            const Spacer(),
            FilledButton(
              onPressed: completed
                  ? () => Navigator.pushNamed(
                        context,
                        '/audit',
                        arguments: _session.actionSession.buildAuditEvent(
                          completedAt: DateTime.now(),
                        ),
                      )
                  : null,
              child: const Text('View audit event'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../widgets/accessible_guidance_banner.dart';

/// Simulated challenge flow — no camera needed.
///
/// Demonstrates the pure Dart state machine by manually advancing steps.
class ChallengeDemoScreen extends StatefulWidget {
  const ChallengeDemoScreen({super.key, this.randomized = false});

  final bool randomized;

  @override
  State<ChallengeDemoScreen> createState() => _ChallengeDemoScreenState();
}

class _ChallengeDemoScreenState extends State<ChallengeDemoScreen>
    with SingleTickerProviderStateMixin {
  late final ChallengeFlowController _controller;
  late final AuditEventBuilder _auditBuilder;
  late final AnimationController _entrance;
  GuidanceMessage? _currentGuidance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _controller = ChallengeFlowController(
      config: FaceChallengeConfig(
        randomize: widget.randomized,
        seed: widget.randomized ? 42 : null,
        sequenceIdPrefix: widget.randomized ? 'random' : 'default',
      ),
    );
    _auditBuilder = AuditEventBuilder(
      sessionId: 'demo-session-${widget.randomized ? 'random' : 'default'}',
      sequenceId: _controller.sequence.sequenceId,
      challengeNonce: _controller.sequence.challengeNonce,
      packageVersion: packageVersion,
    );
    _controller.events.listen(_auditBuilder.recordChallengeEvent);
    _updateGuidance();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _updateGuidance() {
    final step = _controller.state.currentStep;
    if (_controller.state.completed) {
      _currentGuidance = const GuidanceMessageBuilder().challengeCompleted();
      return;
    }
    if (step == null) {
      _currentGuidance = null;
      return;
    }
    _currentGuidance =
        const GuidanceMessageBuilder().forChallengeStep(step).first;
  }

  void _advance() {
    final step = _controller.state.currentStep;
    if (step == null) return;
    _controller.processSignal(_signalFor(step.type));
    _updateGuidance();
    setState(() {});
  }

  FaceActionSignal _signalFor(FaceActionType type) {
    return FaceActionSignal(
      faceDetected: true,
      multipleFacesDetected: false,
      singleFaceDetected: true,
      faceCentered: type == FaceActionType.centerFace,
      faceTooClose: false,
      faceTooFar: false,
      faceOutOfFrame: false,
      blinkDetected: type == FaceActionType.blinkOnce,
      eyesOpen: true,
      headTurnedLeft: type == FaceActionType.turnHeadLeft,
      headTurnedRight: type == FaceActionType.turnHeadRight,
      headTilted: false,
      holdStill: type == FaceActionType.holdStill,
      smileDetected: false,
      qualityStatus: FaceQualityStatus.acceptable,
      positionStatus: FacePositionStatus.centered,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = _controller.state;
    final sequence = _controller.sequence;
    final completed = state.completed;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.randomized ? 'Simulated randomized' : 'Simulated challenge',
        ),
      ),
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _entrance, curve: Curves.easeOut),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Explanation card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Icon(Icons.science_outlined,
                            size: 20, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'State machine test',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No camera needed. Tap "Complete step" to simulate '
                      'each action signal and watch the state machine advance.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (widget.randomized)
                Text(
                  'Sequence: ${sequence.sequenceId} · nonce: ${sequence.challengeNonce ?? '-'}',
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(height: 12),

              // Progress
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: state.progress),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                builder: (_, value, _) => ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    color: completed ? Colors.green : theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                completed
                    ? 'All steps completed!'
                    : 'Step: ${state.currentStep?.instruction ?? '—'}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              if (_currentGuidance != null)
                AccessibleGuidanceBanner(message: _currentGuidance!),
              const SizedBox(height: 16),

              // Steps
              Expanded(
                child: ListView(
                  children: state.steps.map((s) {
                    final passed = s.status == ChallengeStepStatus.passed;
                    final active = s.status == ChallengeStepStatus.inProgress;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: passed
                            ? Colors.green.withValues(alpha: 0.08)
                            : active
                                ? theme.colorScheme.primaryContainer
                                    .withValues(alpha: 0.3)
                                : theme.colorScheme.surfaceContainerHighest
                                    .withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: active
                            ? Border.all(color: theme.colorScheme.primary)
                            : null,
                      ),
                      child: Row(
                        children: <Widget>[
                          if (passed)
                            const Icon(Icons.check_circle,
                                size: 20, color: Colors.green)
                          else if (active)
                            Icon(Icons.radio_button_on,
                                size: 20, color: theme.colorScheme.primary)
                          else
                            Icon(Icons.radio_button_off,
                                size: 20,
                                color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              s.type.name,
                              style: TextStyle(
                                fontWeight:
                                    active ? FontWeight.w600 : FontWeight.w400,
                              ),
                            ),
                          ),
                          Text(
                            s.status.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Actions
              Row(
                children: <Widget>[
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: completed ? null : _advance,
                        icon: const Icon(Icons.skip_next_rounded),
                        label: const Text('Complete step'),
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {
                        _controller.reset();
                        _updateGuidance();
                        setState(() {});
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () {
                  Navigator.pushNamed(context, '/audit',
                      arguments: _auditBuilder);
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('View audit event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

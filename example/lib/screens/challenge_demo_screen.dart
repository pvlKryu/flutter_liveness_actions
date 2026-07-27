import 'package:flutter/material.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

import '../widgets/accessible_guidance_banner.dart';

/// Guided challenge flow demo with optional randomized sequence support.
class ChallengeDemoScreen extends StatefulWidget {
  /// Creates the challenge demo screen.
  const ChallengeDemoScreen({super.key, this.randomized = false});

  /// Whether to use a randomized challenge sequence.
  final bool randomized;

  @override
  State<ChallengeDemoScreen> createState() => _ChallengeDemoScreenState();
}

class _ChallengeDemoScreenState extends State<ChallengeDemoScreen> {
  late final ChallengeFlowController _controller;
  late final AuditEventBuilder _auditBuilder;
  GuidanceMessage? _currentGuidance;

  @override
  void initState() {
    super.initState();
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
      packageVersion: '0.3.0',
    );
    _controller.events.listen(_auditBuilder.recordChallengeEvent);
    _updateGuidance();
  }

  @override
  void dispose() {
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
    if (step == null) {
      return;
    }
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
    final state = _controller.state;
    final sequence = _controller.sequence;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.randomized ? 'Random Challenge' : 'Challenge Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.randomized)
              Text(
                'Sequence: ${sequence.sequenceId} · nonce: ${sequence.challengeNonce ?? '-'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: state.progress),
            const SizedBox(height: 12),
            Text('Progress: ${(state.progress * 100).round()}%'),
            const SizedBox(height: 12),
            Text('Current step: ${state.currentStep?.instruction ?? 'Done'}'),
            const SizedBox(height: 12),
            if (_currentGuidance != null)
              AccessibleGuidanceBanner(message: _currentGuidance!),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: state.steps
                  .map(
                    (s) => Semantics(
                      label: '${s.type.name} ${s.status.name}',
                      child: Chip(
                        label: Text('${s.type.name}: ${s.status.name}'),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    onPressed: state.completed ? null : _advance,
                    child: const Text('Complete current step'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    _controller.reset();
                    _updateGuidance();
                    setState(() {});
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/audit',
                  arguments: _auditBuilder,
                );
              },
              child: const Text('View audit event'),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/diagnostics'),
              child: const Text('View diagnostics'),
            ),
          ],
        ),
      ),
    );
  }
}

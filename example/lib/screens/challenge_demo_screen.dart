import 'package:flutter/material.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

/// Interactive challenge flow demo using simulated derived signals.
class ChallengeDemoScreen extends StatefulWidget {
  /// Creates the challenge demo screen.
  const ChallengeDemoScreen({super.key});

  @override
  State<ChallengeDemoScreen> createState() => _ChallengeDemoScreenState();
}

class _ChallengeDemoScreenState extends State<ChallengeDemoScreen> {
  late final ChallengeFlowController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ChallengeFlowController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _advance() {
    final step = _controller.state.currentStep;
    if (step == null) {
      return;
    }
    _controller.processSignal(_signalFor(step.type));
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
    return Scaffold(
      appBar: AppBar(title: const Text('Challenge Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            LinearProgressIndicator(value: state.progress),
            const SizedBox(height: 12),
            Text('Progress: ${(state.progress * 100).round()}%'),
            const SizedBox(height: 12),
            Text('Current step: ${state.currentStep?.instruction ?? 'Done'}'),
            const SizedBox(height: 24),
            Wrap(
              spacing: 8,
              children: state.steps
                  .map(
                    (s) => Chip(
                      label: Text('${s.type.name}: ${s.status.name}'),
                    ),
                  )
                  .toList(),
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                FilledButton(
                  onPressed: state.completed ? null : _advance,
                  child: const Text('Complete current step'),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    _controller.reset();
                    setState(() {});
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => Navigator.pushNamed(context, '/audit'),
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

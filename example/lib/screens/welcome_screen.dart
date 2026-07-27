import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Choose a demo flow. All processing uses derived face-action '
              'signals only — not identity verification.',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/permission'),
              child: const Text('Live camera demo'),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/live-challenge'),
              child: const Text('Live camera challenge'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () =>
                  Navigator.pushNamed(context, '/live-challenge-random'),
              child: const Text('Live randomized challenge'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => Navigator.pushNamed(context, '/challenge'),
              child: const Text('Simulated challenge flow'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () =>
                  Navigator.pushNamed(context, '/challenge-random'),
              child: const Text('Simulated randomized challenge'),
            ),
          ],
        ),
      ),
    );
  }
}

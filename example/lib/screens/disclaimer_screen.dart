import 'package:flutter/material.dart';

class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Disclaimer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'This example demonstrates liveness-aware face-action signals for mobile onboarding UX.\n'
              'It does not verify identity.\n'
              'It does not make credit decisions.\n'
              'It does not perform KYC/AML.\n'
              'It does not store or upload face images.\n'
              'Do not use this example as a sole security mechanism.',
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/welcome'),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

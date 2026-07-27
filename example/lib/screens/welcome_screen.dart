import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome')),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.pushNamed(context, '/permission'),
          child: const Text('Start challenge demo'),
        ),
      ),
    );
  }
}

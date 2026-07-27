import 'package:flutter/material.dart';

class CameraDemoScreen extends StatelessWidget {
  const CameraDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('Camera preview placeholder'),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
                'Use this screen to integrate camera and ML Kit adapter.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pushNamed(context, '/challenge'),
              child: const Text('Run challenge flow'),
            ),
          ],
        ),
      ),
    );
  }
}

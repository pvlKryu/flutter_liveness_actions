import 'package:flutter/material.dart';

import 'screens/audit_event_screen.dart';
import 'screens/camera_demo_screen.dart';
import 'screens/camera_permission_screen.dart';
import 'screens/challenge_demo_screen.dart';
import 'screens/diagnostics_screen.dart';
import 'screens/disclaimer_screen.dart';
import 'screens/live_challenge_screen.dart';
import 'screens/welcome_screen.dart';

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liveness Actions Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const DisclaimerScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/permission': (_) => const CameraPermissionScreen(),
        '/camera': (_) => const CameraDemoScreen(),
        '/challenge': (_) => const ChallengeDemoScreen(),
        '/challenge-random': (_) => const ChallengeDemoScreen(randomized: true),
        '/live-challenge': (_) => const LiveChallengeScreen(),
        '/live-challenge-random': (_) =>
            const LiveChallengeScreen(randomized: true),
        '/audit': (_) => const AuditEventScreen(),
        '/diagnostics': (_) => const DiagnosticsScreen(),
      },
    );
  }
}

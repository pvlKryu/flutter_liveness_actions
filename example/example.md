# Example app

Android/iOS demo host for [`flutter_liveness_actions`](https://pub.dev/packages/flutter_liveness_actions).

**Not** identity verification, KYC, AML, or fraud prevention — derived face-action signals only. Screenshots use a schematic face placeholder (no real biometric imagery).

## Screenshots

<p align="center">
  <img src="https://raw.githubusercontent.com/pvlKryu/flutter_liveness_actions/main/doc/assets/screenshots/privacy_first.png" width="160" alt="Privacy-first disclaimer" />
  <img src="https://raw.githubusercontent.com/pvlKryu/flutter_liveness_actions/main/doc/assets/screenshots/demo_menu.png" width="160" alt="Demo menu" />
  <img src="https://raw.githubusercontent.com/pvlKryu/flutter_liveness_actions/main/doc/assets/screenshots/realtime_detection.png" width="160" alt="Real-time detection" />
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/pvlKryu/flutter_liveness_actions/main/doc/assets/screenshots/live_challenge.png" width="160" alt="Live challenge" />
  <img src="https://raw.githubusercontent.com/pvlKryu/flutter_liveness_actions/main/doc/assets/screenshots/audit_event.png" width="160" alt="Audit event" />
</p>

## Demo flows

| Demo | What it shows |
| --- | --- |
| Real-time detection | Live HUD (eye/yaw/pitch) + performance profile switching |
| Live camera demo | Preview, oval guide, signal chips |
| Live challenge | Guided blink / turn / hold-still via `LivenessActionSession` |
| Follow the dot | Face-center target path with smooth motion + confetti finale |
| Randomized challenge | Seeded shuffled sequence + nonce |
| Simulated flow | Camera-free state machine (tap to advance steps) |

## Run

```bash
cd example
flutter pub get
flutter run
```

Requires a real **Android** or **iOS** device (or simulator with camera). Grant camera permission when prompted. iOS deployment target is **15.5+** (ML Kit).

## Minimal session wiring

The example feeds ML Kit faces into the package session like this:

```dart
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

final session = LivenessActionSession(
  sessionId: 'demo',
  enableChallenge: true,
  performanceConfig: PerformanceConfig.balanced(),
);

// After converting CameraImage → InputImage → List<Face>:
if (!session.acceptFrame(DateTime.now())) return;
session.markProcessingStarted();
final started = DateTime.now();

final frame = const MlKitFaceAdapter().fromFaces(
  faces,
  imageSize: Size(width, height),
  timestamp: DateTime.now(),
);

final snapshot = session.completeFrame(
  frame,
  DateTime.now().difference(started),
);

// Use snapshot.signal / snapshot.guidance / session.challenge
```

Camera → `InputImage` conversion lives in the **host app** (`lib/services/camera_liveness_session.dart`). The package stays UI-free and camera-agnostic.

## Layout

```
example/lib/
  app.dart                      # routes + Material theme
  services/camera_liveness_session.dart
  screens/                      # disclaimer, demos, audit, diagnostics
  widgets/accessible_guidance_banner.dart
```

## More docs

- Package README: https://github.com/pvlKryu/flutter_liveness_actions#readme
- Platform notes: https://github.com/pvlKryu/flutter_liveness_actions/blob/main/doc/PLATFORM.md
- Device testing: https://github.com/pvlKryu/flutter_liveness_actions/blob/main/doc/DEVICE_TESTING.md

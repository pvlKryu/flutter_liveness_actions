# Dynamic target challenges (1.1.0)

Follow-the-dot challenges are implemented as **face-center target tracking**, not eye tracking. The package evaluates whether the detected face bounding-box center enters target zones over time. This can help create richer real-time onboarding interactions, but it does **not** prove identity or prevent spoofing by itself.

## How it works

1. Host app renders a moving target (dot) using zone coordinates from `DefaultTargetPaths` / `TargetPathFactory`.
2. Camera / ML Kit produces faces → `MlKitFaceAdapter` → `FaceActionFrame`.
3. `TargetPathEvaluator.processFrame(frame)` (or `ChallengeFlowController.processFrame`) checks:
   - normalized face center from `boundingBox` + `imageSize`
   - distance vs zone radius
   - hold duration inside the zone
   - timeout / face lost / multiple faces

No raw images are stored.

## Quick start

```dart
final targetPath = DefaultTargetPaths.simpleCross();
final evaluator = TargetPathEvaluator(
  targets: targetPath,
  sequenceId: 'demo-path',
);

final result = evaluator.processFrame(frame);
// Use evaluator.state / result for UI progress
```

Or as a challenge step:

```dart
final controller = ChallengeFlowController(
  sequenceFactory: /* sequence including followTargetPath */,
);
controller.processFrame(frame);
```

## Presets

| API | Description |
| --- | --- |
| `DefaultTargetPaths.simpleCross()` | center → left → right → center |
| `DefaultTargetPaths.corners()` | center → four corners → center |
| `DefaultTargetPaths.lowEndFriendly()` | larger radius, short path |
| `DefaultTargetPaths.randomized(seed: …)` | deterministic random order |
| `DefaultChallenges.basic()` | classic blink / turn / hold |
| `DefaultChallenges.lowEndFriendly()` | center → blink → hold |
| `DefaultChallenges.extended()` | adds smile + simple follow path |

## Simulator (no camera)

```dart
const sim = TargetChallengeSimulator();
final frames = sim.followTargetSimpleSuccess();
```

Scenarios: simple/corners/low-end success, timeout, face lost, multiple faces, noisy success.

## Low-end Android

Prefer:

- `DefaultChallenges.lowEndFriendly()`
- `DefaultTargetPaths.lowEndFriendly()`
- `PerformanceConfig.lowEndDevice()`
- fewer target steps, larger radius

## Limitations

- Not eye tracking / gaze estimation
- Not identity verification
- Not anti-spoof certification
- Depends on stable face bounding boxes from ML Kit
- Performance varies by device / camera / throttle settings

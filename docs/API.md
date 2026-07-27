# Public API review (0.5.0)

This document records the intended public surface before the 0.9.0 / 1.0.0 freeze.

## Preferred entry points

| API | Use when |
| --- | --- |
| `LivenessActionSession` | You want one object for throttle, analyze, optional challenge, guidance, audit |
| `LivenessActionSnapshot` | You need a per-frame immutable view of session output |
| `packageVersion` | Embed package version in host audit / telemetry |

## Stable building blocks

These are safe for apps that want finer control:

- **Config:** `FaceActionConfig`, `FaceChallengeConfig`, `PerformanceConfig`, `PrivacyConfig`
- **Adapters:** `MlKitFaceAdapter`
- **Analyzers:** `FaceActionAnalyzer`, `BlinkDetector`, `HeadMovementDetector`, `FacePositionAnalyzer`
- **Quality:** `FaceQualityGate`, `FaceQualityWarning`
- **Challenge:** `ChallengeFlowController`, `ChallengeSequenceFactory`, `DefaultChallenges`
- **Performance:** `FrameProcessingController`, `AdaptivePerformanceController`, `DeviceCapabilityProfile`
- **Guidance:** `GuidanceMessageBuilder`, `GuidanceCatalog`, `GuidanceCode`, `GuidanceMessage`
- **Audit:** `AuditEventBuilder`, `AuditTrailRecorder`, `AuditEventExporter`, `OnboardingAuditEvent`
- **Lifecycle:** `LivenessSessionLifecycle`

## Models (value types)

`FaceActionFrame`, `FaceActionSignal`, `FaceActionResult`, `FaceChallengeState`, `FaceChallengeStep`, `FaceChallengeSequence`, `FaceChallengeEvent`, `LivenessDiagnostics`, and related enums.

## Integration sketch

```dart
final session = LivenessActionSession(
  enableChallenge: true,
  challengeConfig: const FaceChallengeConfig(randomize: true, seed: 7),
  sessionId: 'onboarding-1',
);

if (!session.acceptFrame(DateTime.now())) return;
session.markProcessingStarted();
final started = DateTime.now();
final frame = const MlKitFaceAdapter().fromFaces(faces, imageSize: size);
final snap = session.completeFrame(frame, DateTime.now().difference(started));

// Render snap.guidance / snap.challengeState
```

## Not part of the package API

- Camera plugin widgets / controllers
- Permission UX
- Localization catalogs beyond stable `messageKey` strings
- Identity / KYC / fraud outcomes

## Planned before 1.0.0

- Freeze naming of session + challenge APIs
- Confirm ML Kit adapter behavior across Android/iOS image formats
- Expand golden/integration tests for challenge edge cases
- Possibly mark low-level detectors as advanced (docs-only; no hard break yet)

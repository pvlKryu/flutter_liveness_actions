# Public API (0.9.0 release candidate)

This document freezes the intended public surface for the 0.9.0 RC.
Breaking changes after 0.9.0 require a major bump (see [STABILITY.md](STABILITY.md)).

## Preferred entry points

| API | Use when |
| --- | --- |
| `LivenessActionSession` | One object for throttle, analyze, optional challenge, guidance, audit |
| `LivenessActionSnapshot` | Per-frame immutable session output |
| `packageVersion` | Embed package version in host audit / telemetry |

## Primary building blocks

Safe for most host apps:

- **Config:** `FaceActionConfig`, `FaceChallengeConfig`, `PerformanceConfig`, `PrivacyConfig`
- **Adapters:** `MlKitFaceAdapter`
- **Orchestration:** `FaceActionAnalyzer`, `FaceQualityGate`, `ChallengeFlowController`, `ChallengeSequenceFactory`, `DefaultChallenges`
- **Performance:** `FrameProcessingController`, `AdaptivePerformanceController`, `DeviceCapabilityProfile`, `PerformanceProfile`
- **Guidance:** `GuidanceMessageBuilder`, `GuidanceCatalog`, `GuidanceCode`, `GuidanceMessage`, `GuidanceSeverity`
- **Audit:** `AuditEventBuilder`, `AuditTrailRecorder`, `AuditEventExporter`, `OnboardingAuditEvent`
- **Lifecycle:** `LivenessSessionLifecycle`

## Advanced APIs

Exported for customization and testing; prefer the session / analyzer facades in app code:

- `BlinkDetector`, `HeadMovementDetector`, `FacePositionAnalyzer`
- `SignalSmoother`
- `ChallengeStepEvaluator`
- `FaceQualityWarning`, `PrivacyGuard`

## Models (value types)

`FaceActionFrame`, `FaceActionSignal`, `FaceActionResult`, `FaceChallengeState`, `FaceChallengeStep`, `FaceChallengeSequence`, `FaceChallengeEvent`, `FaceChallengeEventType`, `ChallengeFailureReason`, `ChallengeStepStatus`, `FaceActionType`, `FacePositionStatus`, `FaceQualityStatus`, `FaceQualityResult`, `LivenessDiagnostics`, and related enums.

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
- Host localization catalogs beyond stable `messageKey` strings
- Identity / KYC / fraud outcomes

## Platform notes

See [PLATFORM.md](PLATFORM.md) for Android/iOS camera + ML Kit `InputImage` expectations.

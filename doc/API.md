# Public API (1.0.0 stable)

This document describes the **stable** public surface for `1.0.0`.
Breaking changes require a new major version (see [STABILITY.md](STABILITY.md)).

## Preferred entry points

| API | Use when |
| --- | --- |
| `LivenessActionSession` | One object for throttle, analyze, optional challenge, guidance, audit |
| `LivenessActionSnapshot` | Per-frame immutable session output |
| `TargetPathEvaluator` / `DefaultTargetPaths` | Face-center follow-the-dot / moving target flows |
| `TargetChallengeSimulator` | Camera-free target-path tests and demos |
| `packageVersion` | Embed package version in host audit / telemetry |

## Primary building blocks

Safe for most host apps:

- **Config:** `FaceActionConfig`, `FaceChallengeConfig`, `PerformanceConfig`, `PrivacyConfig`
- **Adapters:** `MlKitFaceAdapter`
- **Orchestration:** `FaceActionAnalyzer`, `FaceQualityGate`, `ChallengeFlowController`, `ChallengeSequenceFactory`, `DefaultChallenges`
- **Target path:** `TargetZone`, `FaceTargetPosition`, `TargetZoneResult`, `TargetPathChallenge`, `TargetPathEvaluator`, `TargetPathFactory`, `DefaultTargetPaths`
- **Performance:** `FrameProcessingController`, `AdaptivePerformanceController`, `DeviceCapabilityProfile`, `PerformanceProfile`
- **Guidance:** `GuidanceMessageBuilder`, `GuidanceCatalog`, `GuidanceCode`, `GuidanceMessage`, `GuidanceSeverity`
- **Audit:** `AuditEventBuilder`, `AuditTrailRecorder`, `AuditEventExporter`, `OnboardingAuditEvent`
- **Lifecycle:** `LivenessSessionLifecycle`
- **Simulator:** `TargetChallengeSimulator`

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

# Architecture

`flutter_liveness_actions` is a **camera-agnostic** derived-signal pipeline for mobile onboarding UX. It does **not** perform identity verification, KYC, biometrics matching, or fraud decisions.

## Pipeline

```text
Camera / ML Kit (app-owned)
        │
        ▼
 MlKitFaceAdapter ──► FaceActionFrame
        │
        ▼
 LivenessActionSession (recommended facade)
   ├─ FrameProcessingController (FPS / drop / pause)
   ├─ AdaptivePerformanceController
   ├─ FaceActionAnalyzer
   │    ├─ BlinkDetector
   │    ├─ HeadMovementDetector
   │    ├─ FacePositionAnalyzer
   │    └─ FaceQualityGate
   ├─ ChallengeFlowController (optional)
   ├─ GuidanceMessageBuilder / GuidanceCatalog
   └─ AuditEventBuilder / AuditTrailRecorder
        │
        ▼
 LivenessActionSnapshot
   (signal, quality, guidance, diagnostics, challenge state)
```

## Layers

| Layer | Responsibility | Stability |
| --- | --- | --- |
| **Session facade** (`LivenessActionSession`) | Wire throttle → analyze → challenge → guidance → audit | Preferred integration point |
| **Analyzers / quality** | Derive blink/head/position/quality from frames | Stable-ish; may refine heuristics |
| **Challenge** | Sequence generation and step evaluation | Stable-ish |
| **Guidance / audit** | Localization keys + privacy-safe event timeline | Stable-ish |
| **Adapters** | ML Kit → `FaceActionFrame` mapping | Tied to ML Kit versions |
| **Example camera host** | `camera` plugin + lifecycle | Example-only, not part of package API |

## Design rules

1. **Derived signals only** — no raw image retention in core APIs.
2. **Widget-free core** — hosts own camera UI and accessibility widgets.
3. **Privacy-first audit** — explicit `rawImagesStored: false`, `identityDecision: not_performed`.
4. **Mobile-only** — Android/iOS; no web/desktop support in this major line.
5. **Performance-aware** — adaptive profiles for lower-end Android devices.

## Where camera belongs

Camera capture, permissions, and `InputImage` conversion stay in the **host app** (see `example/lib/services/camera_liveness_session.dart`). The package receives normalized `FaceActionFrame` values.

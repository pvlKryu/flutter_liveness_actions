## 1.1.0

- Added dynamic target / follow-the-dot challenge support.
- Added target-zone interaction models and evaluators.
- Added face-position path tracking for interactive onboarding challenges.
- Added new challenge presets for basic, extended, low-end-friendly, and dynamic target flows.
- Added simulator scenarios for moving-target challenge testing without camera.
- Added documentation for dynamic challenge flows and their limitations.
- Expanded tests for target tracking, path completion, randomized target sequences, and simulator scenarios.

## 1.0.1

- Replaced placeholder LICENSE with the full MIT License.
- Added safe processing-failure handling to prevent stuck frame-processing state after InputImage conversion or ML Kit errors.
- Updated the example app to select Android/iOS camera image formats more safely.
- Improved example camera error handling for unsupported image formats.
- Updated SECURITY.md with a real maintainer contact.
- Documentation and release-readiness polish.

## 1.0.0

- First stable release.
- Public API freeze documented in `doc/API.md` and `doc/STABILITY.md`.
- SemVer compatibility policy for 1.x.
- Documentation and example polish for production host integration.

## 0.9.0

- Release candidate: public API freeze candidate (see `doc/STABILITY.md`, `doc/API.md`).
- Exported `ChallengeStepEvaluator` as an advanced API.
- Platform integration notes for Android/iOS camera + ML Kit (`doc/PLATFORM.md`).
- Publishing checklist (`doc/PUBLISHING.md`) and richer example README.
- Expanded challenge / session edge-case tests and adapter empty-face coverage.
- Challenge retries honor synthetic timestamps (`retryCurrentStep(now:)`).
- Renamed documentation directory to `doc/` for pub.dev layout.
- CI: toolchain logging, publish dry-run, Flutter action cache.

## 0.5.0

- Added `LivenessActionSession` facade for camera-agnostic pipeline orchestration.
- Added `LivenessActionSnapshot` and `packageVersion` constant.
- Expanded docs: architecture, API review, device testing checklist.
- Example: live camera challenge flows (default + randomized) using the session facade.
- CI analyzes the example app; Flutter channel matrix scaffold.
- Additional session integration tests.

## 0.3.0

- Randomized challenge sequences with seed, nonce, and center-face-first option.
- Localization-ready guidance catalog with stable `messageKey` values.
- Accessibility metadata: semantic labels, haptics hints, high-contrast labels, live announcements.
- Advanced audit trail recorder and timeline events in audit JSON.
- Example flows for default and randomized challenges with accessible guidance banner.

## 0.2.0

- Adaptive performance controller with confirmation hysteresis.
- Richer device capability recommendations from latency and drop rate.
- Frame processing pause/resume/reset and config updates.
- Improved quality gate with optional lighting/confidence heuristics.
- Expanded guidance builder (challenge steps, lighting, slow processing, permission).
- Session lifecycle helpers for pause/resume/dispose.
- Face position distinguishes not-centered vs out-of-frame.
- Example app: real camera permission, live camera/ML Kit demo, lifecycle handling, polished diagnostics.
- Android/iOS camera permission setup for the example.

## 0.1.0

- Initial package structure.
- Core face action models.
- ML Kit face adapter.
- Blink detection.
- Head movement detection.
- Face positioning.
- Challenge flow controller.
- Signal smoothing.
- Frame processing diagnostics.
- Privacy-safe audit event builder.
- Example app.
- Unit tests.

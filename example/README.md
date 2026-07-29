# Example app

Demo host for `flutter_liveness_actions` on **Android and iOS**.

This app is for prototypes and UX exploration. It is **not** an identity verification, KYC, or fraud-prevention product.

> The pub.dev **Example** tab renders [`example.md`](example.md) (priority over `lib/main.dart`).

## Flows

| Demo | Purpose |
| --- | --- |
| Real-time detection | Live HUD + performance profile panel |
| Live camera demo | Preview + derived guidance chips |
| Live challenge | Real camera + `LivenessActionSession` challenge |
| Follow the dot | Face-center target path challenge |
| Randomized challenge | Seeded randomized sequence |
| Simulated challenge | Button-driven signals (no camera) |
| Audit / diagnostics | Privacy-safe JSON + performance metrics |

## Run

```bash
cd example
flutter pub get
flutter run
```

Grant camera permission when prompted. iOS requires deployment target **15.5+**.

## Notes

- Camera + ML Kit conversion lives in `lib/services/camera_liveness_session.dart`
- Package core stays camera-agnostic — see `../doc/PLATFORM.md`
- Device validation checklist: `../doc/DEVICE_TESTING.md`

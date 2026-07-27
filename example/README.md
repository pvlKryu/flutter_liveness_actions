# Example app

Demo host for `flutter_liveness_actions` on **Android and iOS**.

This app is for prototypes and UX exploration. It is **not** an identity verification, KYC, or fraud-prevention product.

## Flows

| Route | Purpose |
| --- | --- |
| Live camera demo | Preview + derived guidance chips |
| Live camera challenge | Real camera + `LivenessActionSession` challenge |
| Live randomized challenge | Seeded randomized sequence |
| Simulated challenge | Button-driven signals (no camera) |
| Audit / diagnostics | Privacy-safe JSON + performance metrics |

## Run

```bash
cd example
flutter pub get
flutter run
```

Grant camera permission when prompted.

## Notes

- Camera + ML Kit conversion lives in `lib/services/camera_liveness_session.dart`
- Package core stays camera-agnostic — see `../doc/PLATFORM.md`
- Device validation checklist: `../doc/DEVICE_TESTING.md`

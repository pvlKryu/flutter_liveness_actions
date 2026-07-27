# Device testing checklist

Manual multi-device validation for Android/iOS before 0.9.0 / 1.0.0.

> Core package logic is camera-agnostic. Device variance mostly appears in camera formats, ML Kit timing, and thermal/CPU throttling.

## Matrix (minimum)

| Device class | OS | Priority | Notes |
| --- | --- | --- | --- |
| Mid-range Android | Android 12–14 | P0 | NV21 stream, balanced profile |
| Low-end Android | Android 10–12 | P0 | Expect adaptive → lowEnd/batterySaver |
| Flagship Android | Android 14+ | P1 | High FPS / highPerformance path |
| Recent iPhone | iOS 16+ | P0 | Confirm InputImage format + rotation |
| Older iPhone | iOS 15 | P1 | Lifecycle pause/resume |

## Per-device smoke checklist

Run the **example** app:

1. Disclaimer → Welcome
2. **Live camera demo**
   - Preview appears
   - Guidance updates with face in/out of oval
   - App background/foreground does not crash
3. **Live camera challenge**
   - Steps advance on real actions (blink / turn / center)
   - Progress + chips update
   - Completed audit JSON has `events`, `demoOnly: true`, no raw images
4. **Live randomized challenge**
   - Sequence id / nonce present
   - Center-face-first when configured
5. **Diagnostics**
   - `averageProcessingMs`, drop rate, recommended profile look plausible

## Performance expectations

| Metric | Healthy | Investigate |
| --- | --- | --- |
| Avg processing | < ~80–100 ms mid-range | Sustained > 120 ms |
| Drop rate | < ~30% under load | Persistently high with frozen UI |
| Profile flips | Occasional with hysteresis | Rapid flapping every few seconds |

## Capture for bug reports

- Device model + OS version
- Example route name
- `LivenessDiagnostics` JSON / screen values
- Whether failure is camera init, ML Kit, or challenge evaluation
- Confirm no raw images were stored (expected)

## CI coverage vs device coverage

CI validates format/analyze/unit tests on Linux. It does **not** replace on-device camera/ML Kit validation. Track device runs in release notes for 0.9.0+.

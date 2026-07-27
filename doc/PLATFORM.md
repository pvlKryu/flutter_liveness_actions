# Platform notes (Android / iOS)

The package core is camera-agnostic. Host apps convert camera frames into ML Kit `InputImage`, run face detection, then map results with `MlKitFaceAdapter`.

## Android

| Topic | Recommendation |
| --- | --- |
| Preferred stream format | `ImageFormatGroup.nv21` with the `camera` plugin |
| Sensor rotation | Pass `camera.sensorOrientation` into `InputImageMetadata.rotation` |
| minSdk | Typically 21+ (ML Kit / camera plugin); example uses 24 |
| Permission | `android.permission.CAMERA` |
| Low-end devices | Start with `PerformanceConfig.lowEndDevice()` or let adaptive profiles downshift |

### Common Android pitfalls

- Mismatched `bytesPerRow` / format → empty face lists
- Processing every preview frame without throttle → thermal throttling (use `LivenessActionSession.acceptFrame`)
- Re-creating `FaceDetector` every frame → latency spikes

## iOS

| Topic | Recommendation |
| --- | --- |
| Stream format | Prefer `ImageFormatGroup.bgra8888` when NV21 is unavailable |
| Rotation | Use the active camera description orientation |
| Info.plist | `NSCameraUsageDescription` required |
| Backgrounding | Pause the session on `AppLifecycleState.paused` / `inactive` |

### Common iOS pitfalls

- Using Android-only NV21 assumptions on iOS → `InputImageFormatValue.fromRawValue` returns null
- Not stopping the image stream on dispose → crashes on hot restart
- Simulator: camera / ML Kit behavior differs from devices — validate on hardware

## Adapter contract

`MlKitFaceAdapter`:

- `fromFaces([])` → `faceDetected: false`, `faceCount: 0`
- `fromFaces(nonEmpty)` → maps **first** face as primary, sets `faceCount` to list length
- Never stores image bytes — only derived numeric / geometric fields

## Example host

See `example/lib/services/camera_liveness_session.dart` for a reference loop:

`acceptFrame` → ML Kit `processImage` → `fromFaces` → `completeFrame`.

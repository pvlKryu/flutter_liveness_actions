import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Demo camera + ML Kit host that feeds frames into [LivenessActionSession].
///
/// Processes derived face-action signals only. Does not store or upload images.
///
/// Camera stream formats and `InputImage` conversion are **host-app**
/// responsibilities and may need app-specific handling across devices/plugins.
class CameraLivenessSession extends ChangeNotifier {
  /// Creates a camera host with an optional package [actionSession].
  CameraLivenessSession({
    LivenessActionSession? actionSession,
    PerformanceConfig? initialConfig,
    bool enableChallenge = false,
    FaceChallengeConfig challengeConfig = const FaceChallengeConfig(),
    String sessionId = 'camera-demo',
  }) : _action = actionSession ??
            LivenessActionSession(
              sessionId: sessionId,
              enableChallenge: enableChallenge,
              challengeConfig: challengeConfig,
              performanceConfig: initialConfig ?? PerformanceConfig.balanced(),
            );

  final LivenessActionSession _action;
  final MlKitFaceAdapter _adapter = const MlKitFaceAdapter();

  CameraController? _cameraController;
  FaceDetector? _detector;
  bool _initializing = false;
  bool _disposed = false;
  String? _error;

  /// Underlying package session (signals, challenge, audit, adaptive FPS).
  LivenessActionSession get actionSession => _action;

  /// Camera controller for preview widgets.
  CameraController? get cameraController => _cameraController;

  /// Whether the camera is ready.
  bool get isReady =>
      _cameraController != null &&
      _cameraController!.value.isInitialized &&
      _error == null;

  /// Whether initialization is in progress.
  bool get isInitializing => _initializing;

  /// Last recoverable error message, if any.
  String? get error => _error;

  /// Latest analyzer result.
  FaceActionResult? get latestResult => _action.latestResult;

  /// Current UX guidance messages.
  List<GuidanceMessage> get guidanceMessages => _action.guidanceMessages;

  /// Live processing diagnostics.
  LivenessDiagnostics get diagnostics => _action.diagnostics;

  /// Active performance config.
  PerformanceConfig get performanceConfig => _action.performanceConfig;

  /// Session lifecycle tracker.
  LivenessSessionLifecycle get lifecycle => _action.lifecycle;

  /// Challenge controller when enabled.
  ChallengeFlowController? get challenge => _action.challenge;

  /// Initializes front camera and ML Kit detector.
  Future<void> initialize() async {
    if (_disposed || _initializing || isReady) {
      return;
    }
    _initializing = true;
    _error = null;
    notifyListeners();

    try {
      final cameras = await availableCameras();
      final front = cameras.where(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      if (front.isEmpty) {
        throw StateError('No front camera available on this device.');
      }

      final resolution = _resolutionPreset(_action.performanceConfig);
      final controller = CameraController(
        front.first,
        resolution,
        enableAudio: false,
        // Android: NV21; iOS: BGRA8888 — see doc/PLATFORM.md.
        imageFormatGroup: _imageFormatGroupForPlatform(),
      );
      await controller.initialize();
      if (_disposed) {
        await controller.dispose();
        return;
      }
      _cameraController = controller;

      _detector = FaceDetector(
        options: FaceDetectorOptions(
          enableClassification: true,
          enableTracking: true,
          performanceMode: FaceDetectorMode.accurate,
        ),
      );

      await controller.startImageStream(_onCameraImage);
      _action.resume();
      _action.auditBuilder.recordCameraReady();
    } catch (e) {
      _error = e.toString();
      await disposeCameraOnly();
    } finally {
      _initializing = false;
      if (!_disposed) {
        notifyListeners();
      }
    }
  }

  /// Handles Flutter app lifecycle changes.
  Future<void> handleAppLifecycle(AppLifecycleState state) async {
    if (_disposed) {
      return;
    }
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _action.pause();
        await _stopStreamSafely();
      case AppLifecycleState.resumed:
        _action.resume();
        if (_cameraController != null &&
            _cameraController!.value.isInitialized &&
            !_cameraController!.value.isStreamingImages) {
          await _cameraController!.startImageStream(_onCameraImage);
        }
    }
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> _onCameraImage(CameraImage image) async {
    if (_disposed || !_action.isActive) {
      return;
    }
    final now = DateTime.now();
    if (!_action.acceptFrame(now)) {
      return;
    }

    _action.markProcessingStarted();
    final started = DateTime.now();
    try {
      final input = _toInputImage(image, _cameraController!.description);
      if (input == null) {
        // Unsupported format / conversion failure — release busy state.
        _action.markProcessingFailed();
        return;
      }
      if (_detector == null) {
        _action.markProcessingFailed();
        return;
      }
      final faces = await _detector!.processImage(input);
      final frame = _adapter.fromFaces(
        faces,
        imageSize: Size(image.width.toDouble(), image.height.toDouble()),
        timestamp: now,
      );
      _action.completeFrame(frame, DateTime.now().difference(started));
      if (!_disposed) {
        notifyListeners();
      }
    } catch (_) {
      // ML Kit / conversion errors must not leave the session stuck busy.
      _action.markProcessingFailed();
    }
  }

  /// Preferred camera stream format for ML Kit on this platform.
  ///
  /// Android: NV21. iOS: BGRA8888. Package targets Android/iOS only.
  ImageFormatGroup _imageFormatGroupForPlatform() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ImageFormatGroup.bgra8888;
      case TargetPlatform.android:
        return ImageFormatGroup.nv21;
      default:
        return ImageFormatGroup.nv21;
    }
  }

  /// Builds an [InputImage] for ML Kit, or `null` when unsupported.
  ///
  /// Host apps own camera → `InputImage` conversion. Plane layouts vary by
  /// platform and plugin version; this example keeps a simple single-plane
  /// path and fails closed (returns null) instead of throwing. Image bytes are
  /// never stored or uploaded.
  InputImage? _toInputImage(CameraImage image, CameraDescription camera) {
    final rotation = InputImageRotationValue.fromRawValue(
      camera.sensorOrientation,
    );
    if (rotation == null) {
      return null;
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) {
      return null;
    }

    if (image.planes.isEmpty) {
      return null;
    }

    // Simple example path: use the first plane for NV21 / BGRA8888 streams.
    // Multi-plane YUV layouts may need host-specific handling.
    final plane = image.planes.first;
    if (plane.bytes.isEmpty) {
      return null;
    }

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  ResolutionPreset _resolutionPreset(PerformanceConfig config) {
    switch (config.profile) {
      case PerformanceProfile.highPerformance:
        return ResolutionPreset.high;
      case PerformanceProfile.balanced:
        return ResolutionPreset.medium;
      case PerformanceProfile.lowEndDevice:
      case PerformanceProfile.batterySaver:
        return ResolutionPreset.low;
    }
  }

  Future<void> _stopStreamSafely() async {
    final controller = _cameraController;
    if (controller == null) {
      return;
    }
    try {
      if (controller.value.isStreamingImages) {
        await controller.stopImageStream();
      }
    } catch (_) {
      // Ignore stop races during lifecycle transitions.
    }
  }

  /// Disposes camera resources but keeps analyzers for reuse after re-init.
  Future<void> disposeCameraOnly() async {
    await _stopStreamSafely();
    await _cameraController?.dispose();
    _cameraController = null;
    await _detector?.close();
    _detector = null;
  }

  /// Releases all resources.
  Future<void> close() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    await disposeCameraOnly();
    _action.dispose();
    dispose();
  }
}

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

/// Demo camera + ML Kit session with lifecycle and adaptive performance.
///
/// Processes derived face-action signals only. Does not store or upload images.
class CameraLivenessSession extends ChangeNotifier {
  /// Creates a session with optional initial performance settings.
  CameraLivenessSession({
    PerformanceConfig? initialConfig,
  })  : _adaptive = AdaptivePerformanceController(
          initialConfig: initialConfig ?? PerformanceConfig.balanced(),
        ),
        _lifecycle = LivenessSessionLifecycle() {
    _frameController = FrameProcessingController(config: _adaptive.config);
    _qualityGate = FaceQualityGate(
      enableExtendedQualityChecks: _adaptive.config.enableExtendedQualityChecks,
    );
    _analyzer = FaceActionAnalyzer(qualityGate: _qualityGate);
  }

  final AdaptivePerformanceController _adaptive;
  final LivenessSessionLifecycle _lifecycle;
  final MlKitFaceAdapter _adapter = const MlKitFaceAdapter();
  final GuidanceMessageBuilder _guidance = const GuidanceMessageBuilder();

  late FrameProcessingController _frameController;
  late FaceQualityGate _qualityGate;
  late FaceActionAnalyzer _analyzer;

  CameraController? _cameraController;
  FaceDetector? _detector;
  bool _initializing = false;
  bool _disposed = false;
  String? _error;
  FaceActionResult? _latestResult;
  List<GuidanceMessage> _guidanceMessages = const <GuidanceMessage>[];

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
  FaceActionResult? get latestResult => _latestResult;

  /// Current UX guidance messages.
  List<GuidanceMessage> get guidanceMessages => _guidanceMessages;

  /// Live processing diagnostics.
  LivenessDiagnostics get diagnostics => _frameController.diagnostics();

  /// Active performance config.
  PerformanceConfig get performanceConfig => _adaptive.config;

  /// Session lifecycle tracker.
  LivenessSessionLifecycle get lifecycle => _lifecycle;

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

      final resolution = _resolutionPreset(_adaptive.config);
      final controller = CameraController(
        front.first,
        resolution,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.nv21,
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
          performanceMode: FaceDetectorMode.fast,
        ),
      );

      await controller.startImageStream(_onCameraImage);
      _lifecycle.resume();
      _frameController.resume();
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
        _lifecycle.pause();
        _frameController.pause();
        await _stopStreamSafely();
      case AppLifecycleState.resumed:
        _lifecycle.resume();
        _frameController.resume();
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
    if (_disposed || !_lifecycle.isActive) {
      return;
    }
    final now = DateTime.now();
    if (!_frameController.shouldProcessFrame(now)) {
      return;
    }

    _frameController.markProcessingStarted();
    final started = DateTime.now();
    try {
      final input = _toInputImage(image, _cameraController!.description);
      if (input == null || _detector == null) {
        _frameController.markFrameDropped();
        return;
      }
      final faces = await _detector!.processImage(input);
      final frame = _adapter.fromFaces(
        faces,
        imageSize: Size(image.width.toDouble(), image.height.toDouble()),
        timestamp: now,
      );
      _analyzer.updateDiagnostics(_frameController.diagnostics());
      final result = _analyzer.analyze(frame);
      _latestResult = result;
      _guidanceMessages = _guidance.compose(
        signal: result.signal,
        quality: result.quality,
        diagnostics: _frameController.diagnostics(),
      );

      final changed = _adaptive.observe(_frameController.diagnostics());
      if (changed) {
        _frameController.updateConfig(_adaptive.config);
        _qualityGate = FaceQualityGate(
          enableExtendedQualityChecks:
              _adaptive.config.enableExtendedQualityChecks,
        );
        _analyzer = FaceActionAnalyzer(qualityGate: _qualityGate);
      }
      if (!_disposed) {
        notifyListeners();
      }
    } catch (_) {
      _frameController.markFrameDropped();
    } finally {
      _frameController.markProcessingCompleted(
        DateTime.now().difference(started),
      );
    }
  }

  InputImage? _toInputImage(CameraImage image, CameraDescription camera) {
    final rotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) {
      return null;
    }

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) {
      return null;
    }

    final plane = image.planes.first;
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
    _lifecycle.dispose();
    await disposeCameraOnly();
    _analyzer.reset();
    _frameController.reset();
    dispose();
  }
}

import 'dart:collection';
import 'dart:ui';

import '../models/face_action_frame.dart';

/// Rolling-window temporal filter for noisy face geometry metrics.
///
/// Smooths yaw / pitch / roll and bounding-box center coordinates across the
/// last [windowSize] frames (default 5) using a simple moving average. This
/// reduces detector jitter on low-end hardware that would otherwise cause
/// erratic challenge-state transitions.
///
/// The filter is allocation-light and never stores image bytes. Missing
/// optional metrics are skipped for that frame (buffers are not polluted with
/// zeros), matching [SignalSmoother] behavior for sparse detector output.
class FaceJitterFilter {
  /// Creates a jitter filter with a rolling [windowSize] (must be >= 1).
  FaceJitterFilter({this.windowSize = 5})
      : assert(windowSize >= 1, 'windowSize must be >= 1'),
        _pitch = _RollingAverage(windowSize),
        _yaw = _RollingAverage(windowSize),
        _roll = _RollingAverage(windowSize),
        _centerX = _RollingAverage(windowSize),
        _centerY = _RollingAverage(windowSize),
        _boxWidth = _RollingAverage(windowSize),
        _boxHeight = _RollingAverage(windowSize);

  /// Number of recent samples retained per metric.
  final int windowSize;

  final _RollingAverage _pitch;
  final _RollingAverage _yaw;
  final _RollingAverage _roll;
  final _RollingAverage _centerX;
  final _RollingAverage _centerY;
  final _RollingAverage _boxWidth;
  final _RollingAverage _boxHeight;

  /// Current smoothed geometry snapshot, if at least one sample was accepted.
  SmoothedFaceGeometry? get current => _hasAnySample
      ? SmoothedFaceGeometry(
          headEulerAngleX: _pitch.hasSamples ? _pitch.average : null,
          headEulerAngleY: _yaw.hasSamples ? _yaw.average : null,
          headEulerAngleZ: _roll.hasSamples ? _roll.average : null,
          centerX: _centerX.hasSamples ? _centerX.average : null,
          centerY: _centerY.hasSamples ? _centerY.average : null,
          boxWidth: _boxWidth.hasSamples ? _boxWidth.average : null,
          boxHeight: _boxHeight.hasSamples ? _boxHeight.average : null,
          sampleCount: sampleCount,
        )
      : null;

  /// Largest sample count across active metric buffers.
  int get sampleCount {
    final counts = <int>[
      _pitch.length,
      _yaw.length,
      _roll.length,
      _centerX.length,
      _centerY.length,
    ];
    return counts.reduce((a, b) => a > b ? a : b);
  }

  bool get _hasAnySample =>
      _pitch.hasSamples ||
      _yaw.hasSamples ||
      _roll.hasSamples ||
      _centerX.hasSamples ||
      _centerY.hasSamples;

  /// Pushes [frame] metrics into the rolling buffers and returns a copy with
  /// smoothed euler angles and bounding box (when available).
  ///
  /// Non-geometry fields (eyes, smile, face count, etc.) are preserved as-is.
  FaceActionFrame filter(FaceActionFrame frame) {
    final pitch = frame.headEulerAngleX;
    final yaw = frame.headEulerAngleY;
    final roll = frame.headEulerAngleZ;
    if (pitch != null) {
      _pitch.add(pitch);
    }
    if (yaw != null) {
      _yaw.add(yaw);
    }
    if (roll != null) {
      _roll.add(roll);
    }

    Rect? smoothedBox = frame.boundingBox;
    final box = frame.boundingBox;
    if (box != null) {
      _centerX.add(box.center.dx);
      _centerY.add(box.center.dy);
      _boxWidth.add(box.width);
      _boxHeight.add(box.height);
      final cx = _centerX.average;
      final cy = _centerY.average;
      final w = _boxWidth.average;
      final h = _boxHeight.average;
      smoothedBox = Rect.fromCenter(
        center: Offset(cx, cy),
        width: w,
        height: h,
      );
    }

    return frame.copyWith(
      headEulerAngleX: _pitch.hasSamples ? _pitch.average : pitch,
      headEulerAngleY: _yaw.hasSamples ? _yaw.average : yaw,
      headEulerAngleZ: _roll.hasSamples ? _roll.average : roll,
      boundingBox: smoothedBox,
    );
  }

  /// Clears all rolling buffers.
  void reset() {
    _pitch.clear();
    _yaw.clear();
    _roll.clear();
    _centerX.clear();
    _centerY.clear();
    _boxWidth.clear();
    _boxHeight.clear();
  }
}

/// Snapshot of temporally smoothed face geometry metrics.
class SmoothedFaceGeometry {
  /// Creates a smoothed geometry snapshot.
  const SmoothedFaceGeometry({
    this.headEulerAngleX,
    this.headEulerAngleY,
    this.headEulerAngleZ,
    this.centerX,
    this.centerY,
    this.boxWidth,
    this.boxHeight,
    this.sampleCount = 0,
  });

  /// Smoothed pitch (Euler X), if available.
  final double? headEulerAngleX;

  /// Smoothed yaw (Euler Y), if available.
  final double? headEulerAngleY;

  /// Smoothed roll (Euler Z), if available.
  final double? headEulerAngleZ;

  /// Smoothed bounding-box center X in image coordinates.
  final double? centerX;

  /// Smoothed bounding-box center Y in image coordinates.
  final double? centerY;

  /// Smoothed bounding-box width.
  final double? boxWidth;

  /// Smoothed bounding-box height.
  final double? boxHeight;

  /// Number of samples contributing to the strongest buffer.
  final int sampleCount;
}

class _RollingAverage {
  _RollingAverage(this.maxSize) : assert(maxSize >= 1);

  final int maxSize;
  final Queue<double> _values = Queue<double>();
  double _sum = 0;

  int get length => _values.length;

  bool get hasSamples => _values.isNotEmpty;

  double get average => _values.isEmpty ? 0 : _sum / _values.length;

  void add(double value) {
    _values.addLast(value);
    _sum += value;
    if (_values.length > maxSize) {
      _sum -= _values.removeFirst();
    }
  }

  void clear() {
    _values.clear();
    _sum = 0;
  }
}

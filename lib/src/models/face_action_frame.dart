import 'dart:ui';

import 'package:equatable/equatable.dart';

/// Normalized per-frame face action input.
///
/// Does not include raw camera image bytes.
class FaceActionFrame extends Equatable {
  /// Creates a normalized face action frame.
  const FaceActionFrame({
    required this.timestamp,
    required this.faceDetected,
    required this.faceCount,
    this.leftEyeOpenProbability,
    this.rightEyeOpenProbability,
    this.smilingProbability,
    this.headEulerAngleX,
    this.headEulerAngleY,
    this.headEulerAngleZ,
    this.boundingBox,
    this.imageSize,
    this.hasContours,
    this.hasLandmarks,
    this.brightnessHeuristic,
    this.metadata = const <String, Object?>{},
  });

  /// Capture / analysis timestamp.
  final DateTime timestamp;

  /// Whether at least one face was detected.
  final bool faceDetected;

  /// Number of faces detected in the frame.
  final int faceCount;

  /// Left eye open probability from the detector, if available.
  final double? leftEyeOpenProbability;

  /// Right eye open probability from the detector, if available.
  final double? rightEyeOpenProbability;

  /// Smile probability from the detector, if available.
  final double? smilingProbability;

  /// Head pitch (Euler X), if available from the detector.
  final double? headEulerAngleX;

  /// Head yaw (Euler Y), if available.
  final double? headEulerAngleY;

  /// Head roll (Euler Z), if available.
  final double? headEulerAngleZ;

  /// Face bounding box in image coordinates.
  final Rect? boundingBox;

  /// Source image size used for relative geometry.
  final Size? imageSize;

  /// Whether contours were requested / present.
  final bool? hasContours;

  /// Whether landmarks were requested / present.
  final bool? hasLandmarks;

  /// Optional brightness heuristic in `[0, 1]` (not a calibrated meter).
  ///
  /// Values near `0` suggest low light; values near `1` suggest overexposure.
  /// Apps may estimate this outside the package; core APIs never store images.
  final double? brightnessHeuristic;

  /// Non-PII metadata (for example tracking id).
  final Map<String, Object?> metadata;

  @override
  List<Object?> get props => [
        timestamp,
        faceDetected,
        faceCount,
        leftEyeOpenProbability,
        rightEyeOpenProbability,
        smilingProbability,
        headEulerAngleX,
        headEulerAngleY,
        headEulerAngleZ,
        boundingBox,
        imageSize,
        hasContours,
        hasLandmarks,
        brightnessHeuristic,
        metadata,
      ];
}

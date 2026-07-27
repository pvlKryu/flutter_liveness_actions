import 'dart:ui';

import 'package:equatable/equatable.dart';

/// face action frame.
class FaceActionFrame extends Equatable {
  /// Creates an instance with optional overrides.
  const FaceActionFrame({
    required this.timestamp,
    required this.faceDetected,
    required this.faceCount,
    this.leftEyeOpenProbability,
    this.rightEyeOpenProbability,
    this.smilingProbability,
    this.headEulerAngleY,
    this.headEulerAngleZ,
    this.boundingBox,
    this.imageSize,
    this.hasContours,
    this.hasLandmarks,
    this.metadata = const <String, Object?>{},
  });

  /// timestamp.
  final DateTime timestamp;

  /// face detected.
  final bool faceDetected;

  /// face count.
  final int faceCount;

  /// left eye open probability.
  final double? leftEyeOpenProbability;

  /// right eye open probability.
  final double? rightEyeOpenProbability;

  /// smiling probability.
  final double? smilingProbability;

  /// head euler angle y.
  final double? headEulerAngleY;

  /// head euler angle z.
  final double? headEulerAngleZ;

  /// bounding box.
  final Rect? boundingBox;

  /// image size.
  final Size? imageSize;

  /// has contours.
  final bool? hasContours;

  /// has landmarks.
  final bool? hasLandmarks;

  /// metadata.
  final Map<String, Object?> metadata;

  @override

  /// props.
  List<Object?> get props => [
        timestamp,
        faceDetected,
        faceCount,
        leftEyeOpenProbability,
        rightEyeOpenProbability,
        smilingProbability,
        headEulerAngleY,
        headEulerAngleZ,
        boundingBox,
        imageSize,
        hasContours,
        hasLandmarks,
        metadata,
      ];
}

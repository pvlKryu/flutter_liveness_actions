import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../models/face_action_frame.dart';

/// Normalized face-center position derived from a bounding box.
///
/// Used for face-center target tracking (not eye / gaze tracking).
class FaceTargetPosition extends Equatable {
  /// Creates a face target position.
  const FaceTargetPosition({
    required this.centerX,
    required this.centerY,
    required this.areaRatio,
    required this.isValid,
  });

  /// Normalized face center X (`0` left → `1` right).
  final double centerX;

  /// Normalized face center Y (`0` top → `1` bottom).
  final double centerY;

  /// Face bounding-box area relative to image area.
  final double areaRatio;

  /// Whether geometry was available and usable.
  final bool isValid;

  /// Invalid / unknown position.
  static const FaceTargetPosition invalid = FaceTargetPosition(
    centerX: 0.5,
    centerY: 0.5,
    areaRatio: 0,
    isValid: false,
  );

  /// Computes a normalized position from [frame] geometry.
  factory FaceTargetPosition.fromFrame(FaceActionFrame frame) {
    final box = frame.boundingBox;
    final size = frame.imageSize;
    if (!frame.faceDetected ||
        frame.faceCount != 1 ||
        box == null ||
        size == null ||
        size.width <= 0 ||
        size.height <= 0) {
      return FaceTargetPosition.invalid;
    }

    final centerX = (box.left + box.width / 2) / size.width;
    final centerY = (box.top + box.height / 2) / size.height;
    final areaRatio = (box.width * box.height) / (size.width * size.height);
    return FaceTargetPosition(
      centerX: centerX.clamp(0.0, 1.0),
      centerY: centerY.clamp(0.0, 1.0),
      areaRatio: areaRatio.clamp(0.0, 1.0),
      isValid: true,
    );
  }

  /// Euclidean distance to a normalized target point.
  double distanceToPoint(double targetX, double targetY) {
    final dx = centerX - targetX;
    final dy = centerY - targetY;
    return Offset(dx, dy).distance;
  }

  @override
  List<Object?> get props => [centerX, centerY, areaRatio, isValid];
}

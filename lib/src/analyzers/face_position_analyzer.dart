import '../config/face_action_config.dart';
import '../models/face_action_frame.dart';
import '../models/face_position_status.dart';

/// face position analyzer.
class FacePositionAnalyzer {
  /// Creates an instance with optional overrides.
  const FacePositionAnalyzer({this.config = const FaceActionConfig()});

  /// config.
  final FaceActionConfig config;

  /// analyze.
  FacePositionStatus analyze(FaceActionFrame frame) {
    if (!frame.faceDetected ||
        frame.faceCount <= 0 ||
        frame.boundingBox == null) {
      return FacePositionStatus.noFace;
    }
    if (frame.faceCount > 1) {
      return FacePositionStatus.multipleFaces;
    }
    if (frame.imageSize == null) {
      return FacePositionStatus.unknown;
    }

    final imageW = frame.imageSize!.width;
    final imageH = frame.imageSize!.height;
    final box = frame.boundingBox!;

    if (box.left < 0 ||
        box.top < 0 ||
        box.right > imageW ||
        box.bottom > imageH) {
      return FacePositionStatus.outOfFrame;
    }

    final areaRatio = (box.width * box.height) / (imageW * imageH);
    if (areaRatio > config.maxFaceAreaRatio) {
      return FacePositionStatus.tooClose;
    }
    if (areaRatio < config.minFaceAreaRatio) {
      return FacePositionStatus.tooFar;
    }

    final cx = box.center.dx / imageW;
    final cy = box.center.dy / imageH;
    final centered = (cx - 0.5).abs() <= config.centerTolerance &&
        (cy - 0.5).abs() <= config.centerTolerance;
    return centered
        ? FacePositionStatus.centered
        : FacePositionStatus.notCentered;
  }
}

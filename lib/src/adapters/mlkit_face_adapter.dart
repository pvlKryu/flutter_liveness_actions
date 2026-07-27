import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import '../models/face_action_frame.dart';

/// Maps Google ML Kit [Face] results into package [FaceActionFrame] values.
///
/// This adapter is **derived-signal only**: it never retains camera image bytes.
/// Host apps are responsible for building `InputImage` correctly per platform
/// (see `doc/PLATFORM.md`).
class MlKitFaceAdapter {
  /// Creates an ML Kit face adapter.
  const MlKitFaceAdapter();

  /// Maps a single ML Kit [face] to a normalized [FaceActionFrame].
  FaceActionFrame fromFace(
    Face face, {
    Size? imageSize,
    DateTime? timestamp,
  }) {
    return FaceActionFrame(
      timestamp: timestamp ?? DateTime.now(),
      faceDetected: true,
      faceCount: 1,
      leftEyeOpenProbability: face.leftEyeOpenProbability,
      rightEyeOpenProbability: face.rightEyeOpenProbability,
      smilingProbability: face.smilingProbability,
      headEulerAngleY: face.headEulerAngleY,
      headEulerAngleZ: face.headEulerAngleZ,
      boundingBox: face.boundingBox,
      imageSize: imageSize,
      hasContours: face.contours.isNotEmpty,
      hasLandmarks: face.landmarks.isNotEmpty,
      metadata: <String, Object?>{'trackingId': face.trackingId},
    );
  }

  /// Maps ML Kit [faces] to a single primary [FaceActionFrame].
  ///
  /// When [faces] is empty, returns a no-face frame. Otherwise the **first**
  /// face is treated as primary and [FaceActionFrame.faceCount] reflects the
  /// full list length (used by quality gates for multi-face rejection).
  FaceActionFrame fromFaces(
    List<Face> faces, {
    Size? imageSize,
    DateTime? timestamp,
  }) {
    if (faces.isEmpty) {
      return FaceActionFrame(
        timestamp: timestamp ?? DateTime.now(),
        faceDetected: false,
        faceCount: 0,
        imageSize: imageSize,
      );
    }

    final primary = faces.first;
    return FaceActionFrame(
      timestamp: timestamp ?? DateTime.now(),
      faceDetected: true,
      faceCount: faces.length,
      leftEyeOpenProbability: primary.leftEyeOpenProbability,
      rightEyeOpenProbability: primary.rightEyeOpenProbability,
      smilingProbability: primary.smilingProbability,
      headEulerAngleY: primary.headEulerAngleY,
      headEulerAngleZ: primary.headEulerAngleZ,
      boundingBox: primary.boundingBox,
      imageSize: imageSize,
      hasContours: primary.contours.isNotEmpty,
      hasLandmarks: primary.landmarks.isNotEmpty,
      metadata: <String, Object?>{'trackingId': primary.trackingId},
    );
  }
}

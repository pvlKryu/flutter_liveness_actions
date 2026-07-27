import 'dart:ui';

import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

/// Shared frame builders for unit tests.
class TestFrames {
  static FaceActionFrame centeredFace({
    DateTime? timestamp,
    double eyeOpen = 0.9,
    double yaw = 0,
    double roll = 0,
  }) {
    return FaceActionFrame(
      timestamp: timestamp ?? DateTime.now(),
      faceDetected: true,
      faceCount: 1,
      leftEyeOpenProbability: eyeOpen,
      rightEyeOpenProbability: eyeOpen,
      headEulerAngleY: yaw,
      headEulerAngleZ: roll,
      boundingBox: const Rect.fromLTWH(300, 200, 400, 500),
      imageSize: const Size(1000, 1000),
    );
  }

  static FaceActionFrame noFace({DateTime? timestamp}) {
    return FaceActionFrame(
      timestamp: timestamp ?? DateTime.now(),
      faceDetected: false,
      faceCount: 0,
      imageSize: const Size(1000, 1000),
    );
  }

  static FaceActionFrame multipleFaces({DateTime? timestamp}) {
    return FaceActionFrame(
      timestamp: timestamp ?? DateTime.now(),
      faceDetected: true,
      faceCount: 2,
      boundingBox: const Rect.fromLTWH(300, 200, 400, 500),
      imageSize: const Size(1000, 1000),
    );
  }

  static FaceActionFrame faceAt({
    required Rect box,
    DateTime? timestamp,
    int faceCount = 1,
  }) {
    return FaceActionFrame(
      timestamp: timestamp ?? DateTime.now(),
      faceDetected: true,
      faceCount: faceCount,
      boundingBox: box,
      imageSize: const Size(1000, 1000),
      leftEyeOpenProbability: 0.9,
      rightEyeOpenProbability: 0.9,
    );
  }
}

FaceActionSignal signalForStep(FaceActionType type) {
  return FaceActionSignal(
    faceDetected: true,
    multipleFacesDetected: false,
    singleFaceDetected: true,
    faceCentered: type == FaceActionType.centerFace,
    faceTooClose: false,
    faceTooFar: false,
    faceOutOfFrame: false,
    blinkDetected: type == FaceActionType.blinkOnce,
    eyesOpen: true,
    headTurnedLeft: type == FaceActionType.turnHeadLeft,
    headTurnedRight: type == FaceActionType.turnHeadRight,
    headTilted: false,
    holdStill: type == FaceActionType.holdStill,
    smileDetected: false,
    qualityStatus: FaceQualityStatus.acceptable,
    positionStatus: FacePositionStatus.centered,
  );
}

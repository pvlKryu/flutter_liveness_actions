import 'dart:math' as math;
import 'dart:ui';

import '../models/face_action_frame.dart';
import '../target/target_path_factory.dart';
import '../target/target_zone.dart';

/// Camera-free frame helpers for target-path simulator scenarios.
///
/// Generates derived [FaceActionFrame] values only — never raw images.
class TargetChallengeSimulator {
  /// Creates a simulator helper.
  const TargetChallengeSimulator();

  /// Builds a frame whose face center matches normalized [centerX]/[centerY].
  FaceActionFrame frameWithFaceCenter({
    required DateTime timestamp,
    required double centerX,
    required double centerY,
    double areaRatio = 0.18,
    Size imageSize = const Size(640, 480),
    int faceCount = 1,
    double? smilingProbability,
    double? headEulerAngleY,
  }) {
    if (faceCount <= 0) {
      return FaceActionFrame(
        timestamp: timestamp,
        faceDetected: false,
        faceCount: 0,
        imageSize: imageSize,
      );
    }

    final area = (imageSize.width * imageSize.height) * areaRatio;
    final side = math.sqrt(area).clamp(20.0, imageSize.shortestSide * 0.8);
    final cx = centerX * imageSize.width;
    final cy = centerY * imageSize.height;
    final left = (cx - side / 2).clamp(0.0, imageSize.width - side);
    final top = (cy - side / 2).clamp(0.0, imageSize.height - side);

    return FaceActionFrame(
      timestamp: timestamp,
      faceDetected: true,
      faceCount: faceCount,
      smilingProbability: smilingProbability,
      headEulerAngleY: headEulerAngleY,
      boundingBox: Rect.fromLTWH(left, top, side, side),
      imageSize: imageSize,
    );
  }

  /// Frames that walk through [zones] and hold long enough to complete each.
  List<FaceActionFrame> successPath({
    required List<TargetZone> zones,
    DateTime? start,
    Duration step = const Duration(milliseconds: 100),
    int holdFrames = 6,
    double jitter = 0,
  }) {
    final frames = <FaceActionFrame>[];
    var t = start ?? DateTime.utc(2026, 1, 1);
    for (final zone in zones) {
      for (var i = 0; i < holdFrames; i++) {
        frames.add(
          frameWithFaceCenter(
            timestamp: t,
            centerX: zone.centerX + (i.isEven ? jitter : -jitter),
            centerY: zone.centerY + (i.isOdd ? jitter : -jitter),
          ),
        );
        t = t.add(step);
      }
    }
    return frames;
  }

  /// Scenario: simple cross path succeeds.
  List<FaceActionFrame> followTargetSimpleSuccess() =>
      successPath(zones: DefaultTargetPaths.simpleCross());

  /// Scenario: corners path succeeds.
  List<FaceActionFrame> followTargetCornersSuccess() =>
      successPath(zones: DefaultTargetPaths.corners());

  /// Scenario: low-end friendly path succeeds.
  List<FaceActionFrame> lowEndFollowTargetSuccess() =>
      successPath(zones: DefaultTargetPaths.lowEndFriendly());

  /// Scenario: noisy but still within large enough radius.
  List<FaceActionFrame> followTargetNoisyButSuccess() => successPath(
        zones: DefaultTargetPaths.lowEndFriendly(),
        jitter: 0.03,
        holdFrames: 8,
      );

  /// Scenario: stay off-target until timeout.
  List<FaceActionFrame> followTargetTimeoutFailure({
    Duration span = const Duration(seconds: 10),
  }) {
    final zones = DefaultTargetPaths.simpleCross();
    final target = zones.first;
    final frames = <FaceActionFrame>[];
    var t = DateTime.utc(2026, 1, 1);
    final end = t.add(span);
    while (t.isBefore(end)) {
      frames.add(
        frameWithFaceCenter(
          timestamp: t,
          centerX: (target.centerX + 0.45).clamp(0.0, 1.0),
          centerY: target.centerY,
        ),
      );
      t = t.add(const Duration(milliseconds: 200));
    }
    return frames;
  }

  /// Scenario: face disappears mid-path.
  List<FaceActionFrame> followTargetFaceLostFailure() {
    final zones = DefaultTargetPaths.simpleCross();
    final frames = successPath(zones: zones.take(1).toList(), holdFrames: 3);
    var t = frames.last.timestamp.add(const Duration(milliseconds: 100));
    for (var i = 0; i < 40; i++) {
      frames.add(
        FaceActionFrame(
          timestamp: t,
          faceDetected: false,
          faceCount: 0,
          imageSize: const Size(640, 480),
        ),
      );
      t = t.add(const Duration(milliseconds: 250));
    }
    return frames;
  }

  /// Scenario: multiple faces appear.
  List<FaceActionFrame> followTargetMultipleFacesFailure() {
    final zone = DefaultTargetPaths.simpleCross().first;
    final frames = <FaceActionFrame>[];
    var t = DateTime.utc(2026, 1, 1);
    for (var i = 0; i < 5; i++) {
      frames.add(
        frameWithFaceCenter(
          timestamp: t,
          centerX: zone.centerX,
          centerY: zone.centerY,
          faceCount: 2,
        ),
      );
      t = t.add(const Duration(milliseconds: 100));
    }
    return frames;
  }
}

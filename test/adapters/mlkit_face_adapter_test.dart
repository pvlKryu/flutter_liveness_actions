import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

void main() {
  group('MlKitFaceAdapter', () {
    const adapter = MlKitFaceAdapter();

    test('fromFaces with empty list yields no-face frame', () {
      final frame = adapter.fromFaces(
        const <Face>[],
        imageSize: const Size(640, 480),
        timestamp: DateTime.utc(2026, 7, 27),
      );
      expect(frame.faceDetected, isFalse);
      expect(frame.faceCount, 0);
      expect(frame.imageSize, const Size(640, 480));
      expect(frame.timestamp, DateTime.utc(2026, 7, 27));
      expect(frame.boundingBox, isNull);
      expect(frame.metadata, isEmpty);
    });
  });
}

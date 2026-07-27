import '../models/face_action_signal.dart';
import '../models/guidance_message.dart';
import 'guidance_code.dart';
import 'guidance_severity.dart';

/// guidance message builder.
class GuidanceMessageBuilder {
  /// Creates an instance with optional overrides.
  const GuidanceMessageBuilder();

  /// from signal.
  List<GuidanceMessage> fromSignal(FaceActionSignal signal) {
    if (!signal.faceDetected) {
      return const <GuidanceMessage>[
        GuidanceMessage(
          code: GuidanceCode.noFaceDetected,
          severity: GuidanceSeverity.warning,
          defaultEnglishText:
              'No face detected. Align your face with the guide.',
          semanticLabel: 'No face detected',
        ),
      ];
    }
    if (signal.multipleFacesDetected) {
      return const <GuidanceMessage>[
        GuidanceMessage(
          code: GuidanceCode.onlyOnePerson,
          severity: GuidanceSeverity.error,
          defaultEnglishText: 'Only one person should be visible.',
          semanticLabel: 'Multiple faces detected',
        ),
      ];
    }
    if (signal.faceTooFar) {
      return const <GuidanceMessage>[
        GuidanceMessage(
          code: GuidanceCode.moveCloser,
          severity: GuidanceSeverity.warning,
          defaultEnglishText: 'Move closer to the camera.',
          canUseHapticFeedback: true,
        ),
      ];
    }
    if (signal.faceTooClose) {
      return const <GuidanceMessage>[
        GuidanceMessage(
          code: GuidanceCode.moveFarther,
          severity: GuidanceSeverity.warning,
          defaultEnglishText: 'Move slightly farther from the camera.',
          canUseHapticFeedback: true,
        ),
      ];
    }
    if (signal.faceOutOfFrame || !signal.faceCentered) {
      return const <GuidanceMessage>[
        GuidanceMessage(
          code: GuidanceCode.centerFace,
          severity: GuidanceSeverity.info,
          defaultEnglishText: 'Center your face in the frame.',
          canUseHapticFeedback: true,
        ),
      ];
    }
    if (!signal.holdStill) {
      return const <GuidanceMessage>[
        GuidanceMessage(
          code: GuidanceCode.holdStill,
          severity: GuidanceSeverity.info,
          defaultEnglishText: 'Hold still for a moment.',
          semanticLabel: 'Hold still',
        ),
      ];
    }
    return const <GuidanceMessage>[];
  }
}

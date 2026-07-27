import '../models/challenge_step.dart';
import '../models/face_action_signal.dart';
import '../models/face_action_type.dart';
import '../models/face_quality_result.dart';
import '../models/guidance_message.dart';
import '../models/liveness_diagnostics.dart';
import '../quality/face_quality_warning.dart';
import 'guidance_code.dart';
import 'guidance_severity.dart';

/// Builds accessibility-friendly UX guidance from derived signals.
class GuidanceMessageBuilder {
  /// Creates a guidance message builder.
  const GuidanceMessageBuilder();

  /// Builds guidance from a derived [signal].
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
    if (signal.warnings.contains(FaceQualityWarning.lowLightHeuristic.name) ||
        signal.warnings
            .contains(FaceQualityWarning.overExposedHeuristic.name)) {
      return const <GuidanceMessage>[
        GuidanceMessage(
          code: GuidanceCode.improveLighting,
          severity: GuidanceSeverity.warning,
          defaultEnglishText:
              'Improve lighting. Avoid strong backlight and darkness.',
          semanticLabel: 'Improve lighting',
          canUseHapticFeedback: true,
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
    if (signal.faceOutOfFrame) {
      return const <GuidanceMessage>[
        GuidanceMessage(
          code: GuidanceCode.faceOutOfFrame,
          severity: GuidanceSeverity.warning,
          defaultEnglishText: 'Keep your face fully inside the frame.',
          canUseHapticFeedback: true,
          semanticLabel: 'Face out of frame',
        ),
      ];
    }
    if (!signal.faceCentered) {
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

  /// Builds guidance for the current challenge [step].
  List<GuidanceMessage> forChallengeStep(FaceChallengeStep step) {
    switch (step.type) {
      case FaceActionType.centerFace:
        return const <GuidanceMessage>[
          GuidanceMessage(
            code: GuidanceCode.centerFace,
            severity: GuidanceSeverity.info,
            defaultEnglishText: 'Center your face in the oval.',
            canUseHapticFeedback: true,
            semanticLabel: 'Center face',
          ),
        ];
      case FaceActionType.blinkOnce:
        return const <GuidanceMessage>[
          GuidanceMessage(
            code: GuidanceCode.blinkOnce,
            severity: GuidanceSeverity.info,
            defaultEnglishText: 'Blink once.',
            canUseHapticFeedback: true,
            semanticLabel: 'Blink once',
          ),
        ];
      case FaceActionType.turnHeadLeft:
        return const <GuidanceMessage>[
          GuidanceMessage(
            code: GuidanceCode.turnHeadLeft,
            severity: GuidanceSeverity.info,
            defaultEnglishText: 'Turn your head left.',
            canUseHapticFeedback: true,
            semanticLabel: 'Turn head left',
          ),
        ];
      case FaceActionType.turnHeadRight:
        return const <GuidanceMessage>[
          GuidanceMessage(
            code: GuidanceCode.turnHeadRight,
            severity: GuidanceSeverity.info,
            defaultEnglishText: 'Turn your head right.',
            canUseHapticFeedback: true,
            semanticLabel: 'Turn head right',
          ),
        ];
      case FaceActionType.holdStill:
        return const <GuidanceMessage>[
          GuidanceMessage(
            code: GuidanceCode.holdStill,
            severity: GuidanceSeverity.info,
            defaultEnglishText: 'Hold still.',
            semanticLabel: 'Hold still',
          ),
        ];
    }
  }

  /// Camera permission required message.
  GuidanceMessage cameraPermissionRequired() {
    return const GuidanceMessage(
      code: GuidanceCode.cameraPermissionRequired,
      severity: GuidanceSeverity.error,
      defaultEnglishText: 'Camera permission is required to continue.',
      semanticLabel: 'Camera permission required',
    );
  }

  /// Challenge completed message.
  GuidanceMessage challengeCompleted() {
    return const GuidanceMessage(
      code: GuidanceCode.challengeCompleted,
      severity: GuidanceSeverity.success,
      defaultEnglishText: 'Challenge sequence completed.',
      canUseHapticFeedback: true,
      semanticLabel: 'Challenge completed',
    );
  }

  /// Retry challenge message.
  GuidanceMessage retryChallenge() {
    return const GuidanceMessage(
      code: GuidanceCode.retryChallenge,
      severity: GuidanceSeverity.warning,
      defaultEnglishText: 'Please retry this step.',
      canUseHapticFeedback: true,
      semanticLabel: 'Retry challenge',
    );
  }

  /// Builds a slow-processing warning from [diagnostics], if needed.
  List<GuidanceMessage> fromDiagnostics(LivenessDiagnostics diagnostics) {
    if (diagnostics.averageProcessingMs >= 120) {
      return const <GuidanceMessage>[
        GuidanceMessage(
          code: GuidanceCode.processingSlow,
          severity: GuidanceSeverity.warning,
          defaultEnglishText:
              'Processing is slow on this device. Using safer performance settings.',
          semanticLabel: 'Processing slow',
        ),
      ];
    }
    return const <GuidanceMessage>[];
  }

  /// Merges quality guidance with optional challenge/diagnostics hints.
  List<GuidanceMessage> compose({
    required FaceActionSignal signal,
    FaceChallengeStep? step,
    FaceQualityResult? quality,
    LivenessDiagnostics? diagnostics,
    bool completed = false,
  }) {
    if (completed) {
      return <GuidanceMessage>[challengeCompleted()];
    }
    final messages = <GuidanceMessage>[
      ...fromSignal(signal),
      if (quality != null && quality.guidanceMessages.isNotEmpty)
        ...quality.guidanceMessages,
      if (step != null) ...forChallengeStep(step),
      if (diagnostics != null) ...fromDiagnostics(diagnostics),
    ];

    // Prefer the first highest-severity unique code.
    final seen = <GuidanceCode>{};
    final ordered = messages.toList()
      ..sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return ordered.where((m) => seen.add(m.code)).toList(growable: false);
  }
}

import '../models/challenge_step.dart';
import '../models/face_action_signal.dart';
import '../models/face_action_type.dart';
import '../models/face_quality_result.dart';
import '../models/guidance_message.dart';
import '../models/liveness_diagnostics.dart';
import '../quality/face_quality_warning.dart';
import 'guidance_catalog.dart';
import 'guidance_code.dart';

/// Builds accessibility-friendly UX guidance from derived signals.
class GuidanceMessageBuilder {
  /// Creates a guidance message builder.
  const GuidanceMessageBuilder();

  /// Returns default English instruction text for a challenge [type].
  String instructionTextFor(FaceActionType type) {
    switch (type) {
      case FaceActionType.centerFace:
      case FaceActionType.moveToCenter:
        return GuidanceCatalog.messageFor(GuidanceCode.centerFace)
            .defaultEnglishText;
      case FaceActionType.blinkOnce:
        return GuidanceCatalog.messageFor(GuidanceCode.blinkOnce)
            .defaultEnglishText;
      case FaceActionType.turnHeadLeft:
        return GuidanceCatalog.messageFor(GuidanceCode.turnHeadLeft)
            .defaultEnglishText;
      case FaceActionType.turnHeadRight:
        return GuidanceCatalog.messageFor(GuidanceCode.turnHeadRight)
            .defaultEnglishText;
      case FaceActionType.holdStill:
        return GuidanceCatalog.messageFor(GuidanceCode.holdStill)
            .defaultEnglishText;
      case FaceActionType.smile:
        return GuidanceCatalog.messageFor(GuidanceCode.smile)
            .defaultEnglishText;
      case FaceActionType.followTarget:
      case FaceActionType.followTargetPath:
        return GuidanceCatalog.messageFor(GuidanceCode.followTheDot)
            .defaultEnglishText;
      case FaceActionType.moveToTopLeft:
      case FaceActionType.moveToTopRight:
      case FaceActionType.moveToBottomLeft:
      case FaceActionType.moveToBottomRight:
        return GuidanceCatalog.messageFor(GuidanceCode.moveFaceToTarget)
            .defaultEnglishText;
    }
  }

  /// Builds guidance from a derived [signal].
  List<GuidanceMessage> fromSignal(FaceActionSignal signal) {
    if (!signal.faceDetected) {
      return <GuidanceMessage>[
        GuidanceCatalog.messageFor(GuidanceCode.noFaceDetected),
      ];
    }
    if (signal.multipleFacesDetected) {
      return <GuidanceMessage>[
        GuidanceCatalog.messageFor(GuidanceCode.onlyOnePerson),
      ];
    }
    if (signal.warnings.contains(FaceQualityWarning.lowLightHeuristic.name) ||
        signal.warnings
            .contains(FaceQualityWarning.overExposedHeuristic.name)) {
      return <GuidanceMessage>[
        GuidanceCatalog.messageFor(GuidanceCode.improveLighting),
      ];
    }
    if (signal.faceTooFar) {
      return <GuidanceMessage>[
        GuidanceCatalog.messageFor(GuidanceCode.moveCloser),
      ];
    }
    if (signal.faceTooClose) {
      return <GuidanceMessage>[
        GuidanceCatalog.messageFor(GuidanceCode.moveFarther),
      ];
    }
    if (signal.faceOutOfFrame) {
      return <GuidanceMessage>[
        GuidanceCatalog.messageFor(GuidanceCode.faceOutOfFrame),
      ];
    }
    if (!signal.faceCentered) {
      return <GuidanceMessage>[
        GuidanceCatalog.messageFor(GuidanceCode.centerFace),
      ];
    }
    if (!signal.holdStill) {
      return <GuidanceMessage>[
        GuidanceCatalog.messageFor(GuidanceCode.holdStill),
      ];
    }
    return const <GuidanceMessage>[];
  }

  /// Builds guidance for the current challenge [step].
  List<GuidanceMessage> forChallengeStep(FaceChallengeStep step) {
    switch (step.type) {
      case FaceActionType.centerFace:
      case FaceActionType.moveToCenter:
        return <GuidanceMessage>[
          GuidanceCatalog.messageFor(GuidanceCode.centerFace).copyWith(
            defaultEnglishText: 'Center your face in the oval.',
          ),
        ];
      case FaceActionType.blinkOnce:
        return <GuidanceMessage>[
          GuidanceCatalog.messageFor(GuidanceCode.blinkOnce),
        ];
      case FaceActionType.turnHeadLeft:
        return <GuidanceMessage>[
          GuidanceCatalog.messageFor(GuidanceCode.turnHeadLeft),
        ];
      case FaceActionType.turnHeadRight:
        return <GuidanceMessage>[
          GuidanceCatalog.messageFor(GuidanceCode.turnHeadRight),
        ];
      case FaceActionType.holdStill:
        return <GuidanceMessage>[
          GuidanceCatalog.messageFor(GuidanceCode.holdStill),
        ];
      case FaceActionType.smile:
        return <GuidanceMessage>[
          GuidanceCatalog.messageFor(GuidanceCode.smile),
        ];
      case FaceActionType.followTarget:
      case FaceActionType.followTargetPath:
        return <GuidanceMessage>[
          GuidanceCatalog.messageFor(GuidanceCode.followTheDot),
        ];
      case FaceActionType.moveToTopLeft:
      case FaceActionType.moveToTopRight:
      case FaceActionType.moveToBottomLeft:
      case FaceActionType.moveToBottomRight:
        return <GuidanceMessage>[
          GuidanceCatalog.messageFor(GuidanceCode.moveFaceToTarget),
        ];
    }
  }

  /// Camera permission required message.
  GuidanceMessage cameraPermissionRequired() =>
      GuidanceCatalog.messageFor(GuidanceCode.cameraPermissionRequired);

  /// Challenge completed message.
  GuidanceMessage challengeCompleted() =>
      GuidanceCatalog.messageFor(GuidanceCode.challengeCompleted);

  /// Retry challenge message.
  GuidanceMessage retryChallenge() =>
      GuidanceCatalog.messageFor(GuidanceCode.retryChallenge);

  /// Builds a slow-processing warning from [diagnostics], if needed.
  List<GuidanceMessage> fromDiagnostics(LivenessDiagnostics diagnostics) {
    if (diagnostics.averageProcessingMs >= 120) {
      return <GuidanceMessage>[
        GuidanceCatalog.messageFor(GuidanceCode.processingSlow),
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

    final seen = <GuidanceCode>{};
    final ordered = messages.toList()
      ..sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return ordered.where((m) => seen.add(m.code)).toList(growable: false);
  }
}

extension on GuidanceMessage {
  GuidanceMessage copyWith({String? defaultEnglishText}) {
    return GuidanceMessage(
      code: code,
      messageKey: messageKey,
      severity: severity,
      defaultEnglishText: defaultEnglishText ?? this.defaultEnglishText,
      canUseHapticFeedback: canUseHapticFeedback,
      semanticLabel: semanticLabel,
      announceForAccessibility: announceForAccessibility,
      highContrastLabel: highContrastLabel,
    );
  }
}

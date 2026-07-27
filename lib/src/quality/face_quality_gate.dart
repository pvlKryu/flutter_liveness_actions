import '../analyzers/face_position_analyzer.dart';
import '../guidance/guidance_message_builder.dart';
import '../models/face_action_frame.dart';
import '../models/face_action_signal.dart';
import '../models/face_position_status.dart';
import '../models/face_quality_result.dart';
import '../models/face_quality_status.dart';
import 'face_quality_warning.dart';

/// Evaluates whether a face frame is acceptable for challenge interaction.
class FaceQualityGate {
  /// Creates a gate with optional analyzers and stability requirements.
  FaceQualityGate({
    FacePositionAnalyzer? positionAnalyzer,
    GuidanceMessageBuilder? guidanceBuilder,
    this.requiredStableFrames = 2,
    this.enableExtendedQualityChecks = true,
    this.lowLightThreshold = 0.22,
    this.overExposedThreshold = 0.88,
  })  : _positionAnalyzer = positionAnalyzer ?? const FacePositionAnalyzer(),
        _guidanceBuilder = guidanceBuilder ?? const GuidanceMessageBuilder();

  final FacePositionAnalyzer _positionAnalyzer;
  final GuidanceMessageBuilder _guidanceBuilder;

  /// Consecutive centered frames required before accepting quality.
  final int requiredStableFrames;

  /// Enables optional heuristic checks (brightness / low confidence).
  final bool enableExtendedQualityChecks;

  /// Brightness heuristic below this is treated as low light.
  final double lowLightThreshold;

  /// Brightness heuristic above this is treated as overexposed.
  final double overExposedThreshold;

  int _stableFrames = 0;

  /// Evaluates [frame] and returns quality + guidance.
  FaceQualityResult evaluate(FaceActionFrame frame) {
    final position = _positionAnalyzer.analyze(frame);
    final warnings = <FaceQualityWarning>[];
    FaceQualityStatus status = FaceQualityStatus.unknown;

    switch (position) {
      case FacePositionStatus.noFace:
        status = FaceQualityStatus.noFace;
        warnings.add(FaceQualityWarning.noFace);
      case FacePositionStatus.multipleFaces:
        status = FaceQualityStatus.multipleFaces;
        warnings.add(FaceQualityWarning.multipleFaces);
      case FacePositionStatus.tooClose:
        status = FaceQualityStatus.tooClose;
        warnings.add(FaceQualityWarning.tooClose);
      case FacePositionStatus.tooFar:
        status = FaceQualityStatus.tooFar;
        warnings.add(FaceQualityWarning.tooFar);
      case FacePositionStatus.outOfFrame:
        status = FaceQualityStatus.outOfFrame;
        warnings.add(FaceQualityWarning.outOfFrame);
      case FacePositionStatus.notCentered:
        status = FaceQualityStatus.notCentered;
        warnings.add(FaceQualityWarning.notCentered);
      case FacePositionStatus.centered:
        _stableFrames += 1;
        if (_stableFrames >= requiredStableFrames) {
          status = FaceQualityStatus.acceptable;
        } else {
          status = FaceQualityStatus.unstable;
          warnings.add(FaceQualityWarning.insufficientStableFrames);
        }
      case FacePositionStatus.unknown:
        status = FaceQualityStatus.unknown;
    }

    if (position != FacePositionStatus.centered) {
      _stableFrames = 0;
    }

    if (enableExtendedQualityChecks && frame.faceDetected) {
      final brightness = frame.brightnessHeuristic ??
          (frame.metadata['brightnessHeuristic'] as num?)?.toDouble();
      if (brightness != null) {
        if (brightness < lowLightThreshold) {
          warnings.add(FaceQualityWarning.lowLightHeuristic);
        } else if (brightness > overExposedThreshold) {
          warnings.add(FaceQualityWarning.overExposedHeuristic);
        }
      }
      if (frame.leftEyeOpenProbability == null &&
          frame.rightEyeOpenProbability == null) {
        warnings.add(FaceQualityWarning.lowConfidenceHeuristic);
      }
    }

    // Extended warnings do not hard-fail by default in v0.2; they guide UX.
    final syntheticSignal = FaceActionSignal(
      faceDetected: frame.faceDetected,
      multipleFacesDetected: frame.faceCount > 1,
      singleFaceDetected: frame.faceCount == 1,
      faceCentered: position == FacePositionStatus.centered,
      faceTooClose: position == FacePositionStatus.tooClose,
      faceTooFar: position == FacePositionStatus.tooFar,
      faceOutOfFrame: position == FacePositionStatus.outOfFrame,
      blinkDetected: false,
      eyesOpen: false,
      headTurnedLeft: false,
      headTurnedRight: false,
      headTilted: false,
      holdStill: status == FaceQualityStatus.acceptable,
      smileDetected: false,
      qualityStatus: status,
      positionStatus: position,
      warnings: warnings.map((w) => w.name).toList(growable: false),
    );

    return FaceQualityResult(
      status: status,
      isAcceptable: status == FaceQualityStatus.acceptable,
      warnings: warnings,
      guidanceMessages: _guidanceBuilder.fromSignal(syntheticSignal),
    );
  }

  /// Resets stability counters.
  void reset() {
    _stableFrames = 0;
  }
}

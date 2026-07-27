import '../analyzers/face_position_analyzer.dart';
import '../guidance/guidance_message_builder.dart';
import '../models/face_action_frame.dart';
import '../models/face_action_signal.dart';
import '../models/face_position_status.dart';
import '../models/face_quality_result.dart';
import '../models/face_quality_status.dart';
import 'face_quality_warning.dart';

/// face quality gate.
class FaceQualityGate {
  /// Creates a gate with optional analyzers and [requiredStableFrames].
  FaceQualityGate({
    FacePositionAnalyzer? positionAnalyzer,
    GuidanceMessageBuilder? guidanceBuilder,
    this.requiredStableFrames = 2,
  })  : _positionAnalyzer = positionAnalyzer ?? const FacePositionAnalyzer(),
        _guidanceBuilder = guidanceBuilder ?? const GuidanceMessageBuilder();

  ///  position analyzer.
  final FacePositionAnalyzer _positionAnalyzer;

  ///  guidance builder.
  final GuidanceMessageBuilder _guidanceBuilder;

  /// required stable frames.
  final int requiredStableFrames;
  int _stableFrames = 0;

  /// evaluate.
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
    );

    return FaceQualityResult(
      status: status,
      isAcceptable: status == FaceQualityStatus.acceptable,
      warnings: warnings,
      guidanceMessages: _guidanceBuilder.fromSignal(syntheticSignal),
    );
  }
}

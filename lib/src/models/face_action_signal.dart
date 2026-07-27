import 'package:equatable/equatable.dart';

import 'face_position_status.dart';
import 'face_quality_status.dart';
import 'guidance_message.dart';

/// face action signal.
class FaceActionSignal extends Equatable {
  /// Creates an instance with optional overrides.
  const FaceActionSignal({
    required this.faceDetected,
    required this.multipleFacesDetected,
    required this.singleFaceDetected,
    required this.faceCentered,
    required this.faceTooClose,
    required this.faceTooFar,
    required this.faceOutOfFrame,
    required this.blinkDetected,
    required this.eyesOpen,
    required this.headTurnedLeft,
    required this.headTurnedRight,
    required this.headTilted,
    required this.holdStill,
    required this.smileDetected,
    required this.qualityStatus,
    required this.positionStatus,
    this.guidanceMessages = const <GuidanceMessage>[],
    this.warnings = const <String>[],
  });

  /// face detected.
  final bool faceDetected;

  /// multiple faces detected.
  final bool multipleFacesDetected;

  /// single face detected.
  final bool singleFaceDetected;

  /// face centered.
  final bool faceCentered;

  /// face too close.
  final bool faceTooClose;

  /// face too far.
  final bool faceTooFar;

  /// face out of frame.
  final bool faceOutOfFrame;

  /// blink detected.
  final bool blinkDetected;

  /// eyes open.
  final bool eyesOpen;

  /// head turned left.
  final bool headTurnedLeft;

  /// head turned right.
  final bool headTurnedRight;

  /// head tilted.
  final bool headTilted;

  /// hold still.
  final bool holdStill;

  /// smile detected.
  final bool smileDetected;

  /// quality status.
  final FaceQualityStatus qualityStatus;

  /// position status.
  final FacePositionStatus positionStatus;

  /// guidance messages.
  final List<GuidanceMessage> guidanceMessages;

  /// warnings.
  final List<String> warnings;

  /// Creates an empty signal (no face, no actions detected).
  factory FaceActionSignal.empty() {
    return const FaceActionSignal(
      faceDetected: false,
      multipleFacesDetected: false,
      singleFaceDetected: false,
      faceCentered: false,
      faceTooClose: false,
      faceTooFar: false,
      faceOutOfFrame: false,
      blinkDetected: false,
      eyesOpen: false,
      headTurnedLeft: false,
      headTurnedRight: false,
      headTilted: false,
      holdStill: false,
      smileDetected: false,
      qualityStatus: FaceQualityStatus.unknown,
      positionStatus: FacePositionStatus.unknown,
    );
  }

  @override

  /// props.
  List<Object?> get props => [
        faceDetected,
        multipleFacesDetected,
        singleFaceDetected,
        faceCentered,
        faceTooClose,
        faceTooFar,
        faceOutOfFrame,
        blinkDetected,
        eyesOpen,
        headTurnedLeft,
        headTurnedRight,
        headTilted,
        holdStill,
        smileDetected,
        qualityStatus,
        positionStatus,
        guidanceMessages,
        warnings,
      ];
}

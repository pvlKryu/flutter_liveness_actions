import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_liveness_actions/flutter_liveness_actions.dart';

void main() {
  group('GuidanceMessageBuilder', () {
    const builder = GuidanceMessageBuilder();

    test('returns improveLighting for heuristic warning', () {
      final lit = FaceActionSignal(
        faceDetected: true,
        multipleFacesDetected: false,
        singleFaceDetected: true,
        faceCentered: true,
        faceTooClose: false,
        faceTooFar: false,
        faceOutOfFrame: false,
        blinkDetected: false,
        eyesOpen: true,
        headTurnedLeft: false,
        headTurnedRight: false,
        headTilted: false,
        holdStill: true,
        smileDetected: false,
        qualityStatus: FaceQualityStatus.acceptable,
        positionStatus: FacePositionStatus.centered,
        warnings: <String>[FaceQualityWarning.lowLightHeuristic.name],
      );
      final messages = builder.fromSignal(lit);
      expect(messages.first.code, GuidanceCode.improveLighting);
    });

    test('builds challenge step guidance', () {
      const step = FaceChallengeStep(
        id: '1',
        type: FaceActionType.blinkOnce,
        instruction: 'Blink once.',
        status: ChallengeStepStatus.inProgress,
      );
      expect(
        builder.forChallengeStep(step).first.code,
        GuidanceCode.blinkOnce,
      );
    });

    test('flags slow processing', () {
      final messages = builder.fromDiagnostics(
        const LivenessDiagnostics(averageProcessingMs: 140),
      );
      expect(messages.first.code, GuidanceCode.processingSlow);
    });
  });
}

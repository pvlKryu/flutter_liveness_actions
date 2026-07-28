import '../models/face_action_type.dart';
import '../models/guidance_message.dart';
import 'guidance_code.dart';
import 'guidance_message_builder.dart';
import 'guidance_severity.dart';

/// Localization-ready catalog of default guidance messages.
class GuidanceCatalog {
  const GuidanceCatalog._();

  static const GuidanceMessageBuilder _builder = GuidanceMessageBuilder();

  /// Stable localization key prefix for guidance strings.
  static const String keyPrefix = 'guidance';

  /// Returns the default English instruction for a challenge [action].
  static String instructionFor(FaceActionType action) {
    return _builder.instructionTextFor(action);
  }

  /// Returns the canonical [GuidanceMessage] for [code].
  static GuidanceMessage messageFor(GuidanceCode code) {
    switch (code) {
      case GuidanceCode.moveCloser:
        return _moveCloser;
      case GuidanceCode.moveFarther:
        return _moveFarther;
      case GuidanceCode.centerFace:
        return _centerFace;
      case GuidanceCode.improveLighting:
        return _improveLighting;
      case GuidanceCode.holdStill:
        return _holdStill;
      case GuidanceCode.blinkOnce:
        return _blinkOnce;
      case GuidanceCode.turnHeadLeft:
        return _turnHeadLeft;
      case GuidanceCode.turnHeadRight:
        return _turnHeadRight;
      case GuidanceCode.onlyOnePerson:
        return _onlyOnePerson;
      case GuidanceCode.cameraPermissionRequired:
        return _cameraPermissionRequired;
      case GuidanceCode.challengeCompleted:
        return _challengeCompleted;
      case GuidanceCode.retryChallenge:
        return _retryChallenge;
      case GuidanceCode.processingSlow:
        return _processingSlow;
      case GuidanceCode.faceOutOfFrame:
        return _faceOutOfFrame;
      case GuidanceCode.noFaceDetected:
        return _noFaceDetected;
      case GuidanceCode.smile:
        return _smile;
      case GuidanceCode.followTheDot:
        return _followTheDot;
      case GuidanceCode.moveFaceToTarget:
        return _moveFaceToTarget;
      case GuidanceCode.holdInsideTarget:
        return _holdInsideTarget;
      case GuidanceCode.targetCompleted:
        return _targetCompleted;
      case GuidanceCode.targetMissed:
        return _targetMissed;
      case GuidanceCode.faceLostDuringTargetChallenge:
        return _faceLostDuringTargetChallenge;
      case GuidanceCode.targetChallengeTimeout:
        return _targetChallengeTimeout;
      case GuidanceCode.moveSlightlyLeft:
        return _moveSlightlyLeft;
      case GuidanceCode.moveSlightlyRight:
        return _moveSlightlyRight;
      case GuidanceCode.moveSlightlyUp:
        return _moveSlightlyUp;
      case GuidanceCode.moveSlightlyDown:
        return _moveSlightlyDown;
    }
  }

  /// All built-in guidance messages for localization extraction.
  static List<GuidanceMessage> allMessages() =>
      GuidanceCode.values.map(messageFor).toList(growable: false);

  static const GuidanceMessage _moveCloser = GuidanceMessage(
    code: GuidanceCode.moveCloser,
    messageKey: '$keyPrefix.move_closer',
    severity: GuidanceSeverity.warning,
    defaultEnglishText: 'Move closer to the camera.',
    canUseHapticFeedback: true,
    semanticLabel: 'Move closer',
    announceForAccessibility: true,
    highContrastLabel: 'Closer',
  );

  static const GuidanceMessage _moveFarther = GuidanceMessage(
    code: GuidanceCode.moveFarther,
    messageKey: '$keyPrefix.move_farther',
    severity: GuidanceSeverity.warning,
    defaultEnglishText: 'Move slightly farther from the camera.',
    canUseHapticFeedback: true,
    semanticLabel: 'Move farther',
    announceForAccessibility: true,
    highContrastLabel: 'Farther',
  );

  static const GuidanceMessage _centerFace = GuidanceMessage(
    code: GuidanceCode.centerFace,
    messageKey: '$keyPrefix.center_face',
    severity: GuidanceSeverity.info,
    defaultEnglishText: 'Center your face in the frame.',
    canUseHapticFeedback: true,
    semanticLabel: 'Center face',
    announceForAccessibility: true,
    highContrastLabel: 'Center',
  );

  static const GuidanceMessage _improveLighting = GuidanceMessage(
    code: GuidanceCode.improveLighting,
    messageKey: '$keyPrefix.improve_lighting',
    severity: GuidanceSeverity.warning,
    defaultEnglishText:
        'Improve lighting. Avoid strong backlight and darkness.',
    semanticLabel: 'Improve lighting',
    canUseHapticFeedback: true,
    announceForAccessibility: true,
    highContrastLabel: 'Lighting',
  );

  static const GuidanceMessage _holdStill = GuidanceMessage(
    code: GuidanceCode.holdStill,
    messageKey: '$keyPrefix.hold_still',
    severity: GuidanceSeverity.info,
    defaultEnglishText: 'Hold still for a moment.',
    semanticLabel: 'Hold still',
    announceForAccessibility: true,
    highContrastLabel: 'Still',
  );

  static const GuidanceMessage _blinkOnce = GuidanceMessage(
    code: GuidanceCode.blinkOnce,
    messageKey: '$keyPrefix.blink_once',
    severity: GuidanceSeverity.info,
    defaultEnglishText: 'Blink once.',
    canUseHapticFeedback: true,
    semanticLabel: 'Blink once',
    announceForAccessibility: true,
    highContrastLabel: 'Blink',
  );

  static const GuidanceMessage _turnHeadLeft = GuidanceMessage(
    code: GuidanceCode.turnHeadLeft,
    messageKey: '$keyPrefix.turn_head_left',
    severity: GuidanceSeverity.info,
    defaultEnglishText: 'Turn your head left.',
    canUseHapticFeedback: true,
    semanticLabel: 'Turn head left',
    announceForAccessibility: true,
    highContrastLabel: 'Left',
  );

  static const GuidanceMessage _turnHeadRight = GuidanceMessage(
    code: GuidanceCode.turnHeadRight,
    messageKey: '$keyPrefix.turn_head_right',
    severity: GuidanceSeverity.info,
    defaultEnglishText: 'Turn your head right.',
    canUseHapticFeedback: true,
    semanticLabel: 'Turn head right',
    announceForAccessibility: true,
    highContrastLabel: 'Right',
  );

  static const GuidanceMessage _onlyOnePerson = GuidanceMessage(
    code: GuidanceCode.onlyOnePerson,
    messageKey: '$keyPrefix.only_one_person',
    severity: GuidanceSeverity.error,
    defaultEnglishText: 'Only one person should be visible.',
    semanticLabel: 'Multiple faces detected',
    announceForAccessibility: true,
    highContrastLabel: 'One person',
  );

  static const GuidanceMessage _cameraPermissionRequired = GuidanceMessage(
    code: GuidanceCode.cameraPermissionRequired,
    messageKey: '$keyPrefix.camera_permission_required',
    severity: GuidanceSeverity.error,
    defaultEnglishText: 'Camera permission is required to continue.',
    semanticLabel: 'Camera permission required',
    announceForAccessibility: true,
    highContrastLabel: 'Permission',
  );

  static const GuidanceMessage _challengeCompleted = GuidanceMessage(
    code: GuidanceCode.challengeCompleted,
    messageKey: '$keyPrefix.challenge_completed',
    severity: GuidanceSeverity.success,
    defaultEnglishText: 'Challenge sequence completed.',
    canUseHapticFeedback: true,
    semanticLabel: 'Challenge completed',
    announceForAccessibility: true,
    highContrastLabel: 'Done',
  );

  static const GuidanceMessage _retryChallenge = GuidanceMessage(
    code: GuidanceCode.retryChallenge,
    messageKey: '$keyPrefix.retry_challenge',
    severity: GuidanceSeverity.warning,
    defaultEnglishText: 'Please retry this step.',
    canUseHapticFeedback: true,
    semanticLabel: 'Retry challenge',
    announceForAccessibility: true,
    highContrastLabel: 'Retry',
  );

  static const GuidanceMessage _processingSlow = GuidanceMessage(
    code: GuidanceCode.processingSlow,
    messageKey: '$keyPrefix.processing_slow',
    severity: GuidanceSeverity.warning,
    defaultEnglishText:
        'Processing is slow on this device. Using safer performance settings.',
    semanticLabel: 'Processing slow',
    announceForAccessibility: true,
    highContrastLabel: 'Slow',
  );

  static const GuidanceMessage _faceOutOfFrame = GuidanceMessage(
    code: GuidanceCode.faceOutOfFrame,
    messageKey: '$keyPrefix.face_out_of_frame',
    severity: GuidanceSeverity.warning,
    defaultEnglishText: 'Keep your face fully inside the frame.',
    canUseHapticFeedback: true,
    semanticLabel: 'Face out of frame',
    announceForAccessibility: true,
    highContrastLabel: 'In frame',
  );

  static const GuidanceMessage _noFaceDetected = GuidanceMessage(
    code: GuidanceCode.noFaceDetected,
    messageKey: '$keyPrefix.no_face_detected',
    severity: GuidanceSeverity.warning,
    defaultEnglishText: 'No face detected. Align your face with the guide.',
    semanticLabel: 'No face detected',
    announceForAccessibility: true,
    highContrastLabel: 'No face',
  );

  static const GuidanceMessage _smile = GuidanceMessage(
    code: GuidanceCode.smile,
    messageKey: '$keyPrefix.smile',
    severity: GuidanceSeverity.info,
    defaultEnglishText: 'Smile.',
    canUseHapticFeedback: true,
    semanticLabel: 'Smile',
    announceForAccessibility: true,
    highContrastLabel: 'Smile',
  );

  static const GuidanceMessage _followTheDot = GuidanceMessage(
    code: GuidanceCode.followTheDot,
    messageKey: '$keyPrefix.follow_the_dot',
    severity: GuidanceSeverity.info,
    defaultEnglishText: 'Follow the target with your face.',
    canUseHapticFeedback: true,
    semanticLabel: 'Follow the target',
    announceForAccessibility: true,
    highContrastLabel: 'Follow',
  );

  static const GuidanceMessage _moveFaceToTarget = GuidanceMessage(
    code: GuidanceCode.moveFaceToTarget,
    messageKey: '$keyPrefix.move_face_to_target',
    severity: GuidanceSeverity.info,
    defaultEnglishText: 'Move your face toward the dot.',
    canUseHapticFeedback: true,
    semanticLabel: 'Move face toward target',
    announceForAccessibility: true,
    highContrastLabel: 'To target',
  );

  static const GuidanceMessage _holdInsideTarget = GuidanceMessage(
    code: GuidanceCode.holdInsideTarget,
    messageKey: '$keyPrefix.hold_inside_target',
    severity: GuidanceSeverity.info,
    defaultEnglishText: 'Hold still inside the target.',
    semanticLabel: 'Hold inside target',
    announceForAccessibility: true,
    highContrastLabel: 'Hold',
  );

  static const GuidanceMessage _targetCompleted = GuidanceMessage(
    code: GuidanceCode.targetCompleted,
    messageKey: '$keyPrefix.target_completed',
    severity: GuidanceSeverity.success,
    defaultEnglishText: 'Target completed.',
    canUseHapticFeedback: true,
    semanticLabel: 'Target completed',
    announceForAccessibility: true,
    highContrastLabel: 'Done',
  );

  static const GuidanceMessage _targetMissed = GuidanceMessage(
    code: GuidanceCode.targetMissed,
    messageKey: '$keyPrefix.target_missed',
    severity: GuidanceSeverity.warning,
    defaultEnglishText: 'Target missed. Try again.',
    canUseHapticFeedback: true,
    semanticLabel: 'Target missed',
    announceForAccessibility: true,
    highContrastLabel: 'Missed',
  );

  static const GuidanceMessage _faceLostDuringTargetChallenge = GuidanceMessage(
    code: GuidanceCode.faceLostDuringTargetChallenge,
    messageKey: '$keyPrefix.face_lost_during_target_challenge',
    severity: GuidanceSeverity.warning,
    defaultEnglishText: 'Face lost — center your face again.',
    semanticLabel: 'Face lost during target challenge',
    announceForAccessibility: true,
    highContrastLabel: 'Face lost',
  );

  static const GuidanceMessage _targetChallengeTimeout = GuidanceMessage(
    code: GuidanceCode.targetChallengeTimeout,
    messageKey: '$keyPrefix.target_challenge_timeout',
    severity: GuidanceSeverity.error,
    defaultEnglishText: 'Target challenge timed out.',
    canUseHapticFeedback: true,
    semanticLabel: 'Target challenge timeout',
    announceForAccessibility: true,
    highContrastLabel: 'Timeout',
  );

  static const GuidanceMessage _moveSlightlyLeft = GuidanceMessage(
    code: GuidanceCode.moveSlightlyLeft,
    messageKey: '$keyPrefix.move_slightly_left',
    severity: GuidanceSeverity.info,
    defaultEnglishText: 'Move slightly left.',
    semanticLabel: 'Move slightly left',
    announceForAccessibility: true,
    highContrastLabel: 'Left',
  );

  static const GuidanceMessage _moveSlightlyRight = GuidanceMessage(
    code: GuidanceCode.moveSlightlyRight,
    messageKey: '$keyPrefix.move_slightly_right',
    severity: GuidanceSeverity.info,
    defaultEnglishText: 'Move slightly right.',
    semanticLabel: 'Move slightly right',
    announceForAccessibility: true,
    highContrastLabel: 'Right',
  );

  static const GuidanceMessage _moveSlightlyUp = GuidanceMessage(
    code: GuidanceCode.moveSlightlyUp,
    messageKey: '$keyPrefix.move_slightly_up',
    severity: GuidanceSeverity.info,
    defaultEnglishText: 'Move slightly up.',
    semanticLabel: 'Move slightly up',
    announceForAccessibility: true,
    highContrastLabel: 'Up',
  );

  static const GuidanceMessage _moveSlightlyDown = GuidanceMessage(
    code: GuidanceCode.moveSlightlyDown,
    messageKey: '$keyPrefix.move_slightly_down',
    severity: GuidanceSeverity.info,
    defaultEnglishText: 'Move slightly down.',
    semanticLabel: 'Move slightly down',
    announceForAccessibility: true,
    highContrastLabel: 'Down',
  );
}

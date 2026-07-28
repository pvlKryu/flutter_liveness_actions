import '../config/face_action_config.dart';
import '../models/challenge_failure_reason.dart';
import '../models/face_action_frame.dart';
import 'face_target_position.dart';
import 'target_path_challenge.dart';
import 'target_zone.dart';
import 'target_zone_result.dart';

/// Evaluates [FaceActionFrame] geometry against a [TargetPathChallenge].
///
/// Uses only bounding-box + image size (face-center tracking). Not eye tracking.
class TargetPathEvaluator {
  /// Creates an evaluator for [targets].
  TargetPathEvaluator({
    required List<TargetZone> targets,
    String sequenceId = 'target-path',
    String? challengeNonce,
    FaceActionConfig config = const FaceActionConfig(),
    this.failOnFaceLost = true,
    this.failOnMultipleFaces = true,
  })  : _config = config,
        _state = TargetPathChallenge.initial(
          sequenceId: sequenceId,
          targets: targets,
          challengeNonce: challengeNonce,
        );

  final FaceActionConfig _config;
  TargetPathChallenge _state;
  DateTime? _targetStartedAt;
  DateTime? _insideSince;
  int _stableInsideFrames = 0;

  /// Whether losing the face fails the path.
  final bool failOnFaceLost;

  /// Whether multiple faces fail the path.
  final bool failOnMultipleFaces;

  /// Current path snapshot.
  TargetPathChallenge get state => _state;

  /// Active target zone, if any.
  TargetZone? get currentTarget => _state.currentTarget;

  /// Resets path progress.
  void reset({List<TargetZone>? targets, String? sequenceId}) {
    _state = TargetPathChallenge.initial(
      sequenceId: sequenceId ?? _state.sequenceId,
      targets: targets ?? _state.targets,
      challengeNonce: _state.challengeNonce,
    );
    _targetStartedAt = null;
    _insideSince = null;
    _stableInsideFrames = 0;
  }

  /// Processes one frame and returns the active-zone evaluation result.
  TargetZoneResult processFrame(FaceActionFrame frame) {
    if (_state.completed || _state.failed || _state.currentTarget == null) {
      final target = _state.currentTarget;
      return TargetZoneResult(
        targetId: target?.id ?? 'none',
        inside: false,
        distanceToCenter: 0,
        requiredRadius: target?.radius ?? _config.targetZoneDefaultRadius,
        heldFor: Duration.zero,
        completed: _state.completed,
        timedOut: false,
        pathCompleted: _state.completed,
        pathFailed: _state.failed,
      );
    }

    final target = _state.currentTarget!;
    _targetStartedAt ??= frame.timestamp;

    if (frame.faceCount > 1) {
      _insideSince = null;
      _stableInsideFrames = 0;
      if (failOnMultipleFaces) {
        _fail(ChallengeFailureReason.multipleFaces, target.id);
      }
      return TargetZoneResult(
        targetId: target.id,
        inside: false,
        distanceToCenter: 0,
        requiredRadius: _radiusFor(target),
        heldFor: Duration.zero,
        completed: false,
        timedOut: false,
        multipleFaces: true,
        pathFailed: _state.failed,
      );
    }

    if (!frame.faceDetected || frame.faceCount == 0) {
      _insideSince = null;
      _stableInsideFrames = 0;
      if (failOnFaceLost) {
        final elapsed = frame.timestamp.difference(_targetStartedAt!);
        if (elapsed > target.timeout) {
          _fail(ChallengeFailureReason.lostFace, target.id);
          return TargetZoneResult(
            targetId: target.id,
            inside: false,
            distanceToCenter: 0,
            requiredRadius: _radiusFor(target),
            heldFor: Duration.zero,
            completed: false,
            timedOut: true,
            faceLost: true,
            pathFailed: true,
          );
        }
      }
      return TargetZoneResult(
        targetId: target.id,
        inside: false,
        distanceToCenter: 0,
        requiredRadius: _radiusFor(target),
        heldFor: Duration.zero,
        completed: false,
        timedOut: false,
        faceLost: true,
        pathFailed: _state.failed,
      );
    }

    final position = FaceTargetPosition.fromFrame(frame);
    final radius = _radiusFor(target);
    final distance = position.isValid
        ? position.distanceToPoint(target.centerX, target.centerY)
        : double.infinity;
    final inside = position.isValid && distance <= radius;
    final elapsed = frame.timestamp.difference(_targetStartedAt!);

    if (elapsed > target.timeout) {
      _fail(ChallengeFailureReason.timeout, target.id);
      return TargetZoneResult(
        targetId: target.id,
        inside: inside,
        distanceToCenter: distance.isFinite ? distance : 0,
        requiredRadius: radius,
        heldFor: Duration.zero,
        completed: false,
        timedOut: true,
        pathFailed: true,
        guidanceHint: _hint(position, target),
      );
    }

    Duration heldFor = Duration.zero;
    if (inside) {
      _insideSince ??= frame.timestamp;
      _stableInsideFrames += 1;
      heldFor = frame.timestamp.difference(_insideSince!);
      final holdOk = heldFor >= target.holdDuration &&
          _stableInsideFrames >= _config.requiredTargetStableFrames;
      if (holdOk) {
        return _completeCurrent(target, distance, radius, heldFor);
      }
    } else {
      _insideSince = null;
      _stableInsideFrames = 0;
    }

    return TargetZoneResult(
      targetId: target.id,
      inside: inside,
      distanceToCenter: distance.isFinite ? distance : 0,
      requiredRadius: radius,
      heldFor: heldFor,
      completed: false,
      timedOut: false,
      pathCompleted: false,
      pathFailed: false,
      guidanceHint: _hint(position, target),
    );
  }

  TargetZoneResult _completeCurrent(
    TargetZone target,
    double distance,
    double radius,
    Duration heldFor,
  ) {
    final completedTargets = _state.completedTargets + 1;
    final nextIndex = _state.currentIndex + 1;
    final done = nextIndex >= _state.targets.length;
    _state = _state.copyWith(
      currentIndex: done ? _state.currentIndex : nextIndex,
      completed: done,
      progress: completedTargets / _state.targets.length,
      completedTargets: completedTargets,
    );
    _targetStartedAt = null;
    _insideSince = null;
    _stableInsideFrames = 0;

    return TargetZoneResult(
      targetId: target.id,
      inside: true,
      distanceToCenter: distance,
      requiredRadius: radius,
      heldFor: heldFor,
      completed: true,
      timedOut: false,
      pathCompleted: done,
      pathFailed: false,
    );
  }

  void _fail(ChallengeFailureReason reason, String targetId) {
    _state = _state.copyWith(
      failed: true,
      failureReason: reason,
      failedTargetId: targetId,
    );
  }

  double _radiusFor(TargetZone target) {
    return target.radius > 0 ? target.radius : _config.targetZoneDefaultRadius;
  }

  String? _hint(FaceTargetPosition position, TargetZone target) {
    if (!position.isValid) {
      return null;
    }
    final dx = target.centerX - position.centerX;
    final dy = target.centerY - position.centerY;
    if (dx.abs() >= dy.abs()) {
      return dx > 0 ? 'right' : 'left';
    }
    return dy > 0 ? 'down' : 'up';
  }
}

import 'package:equatable/equatable.dart';

/// Per-frame evaluation result for the active [TargetZone].
class TargetZoneResult extends Equatable {
  /// Creates a target-zone evaluation result.
  const TargetZoneResult({
    required this.targetId,
    required this.inside,
    required this.distanceToCenter,
    required this.requiredRadius,
    required this.heldFor,
    required this.completed,
    required this.timedOut,
    this.faceLost = false,
    this.multipleFaces = false,
    this.pathCompleted = false,
    this.pathFailed = false,
    this.guidanceHint,
  });

  /// Active target zone id.
  final String targetId;

  /// Whether the face center is inside the zone radius.
  final bool inside;

  /// Euclidean distance from face center to target center (normalized).
  final double distanceToCenter;

  /// Required acceptance radius.
  final double requiredRadius;

  /// Continuous hold time inside the zone so far.
  final Duration heldFor;

  /// Whether this zone was completed on this frame.
  final bool completed;

  /// Whether this zone timed out on this frame.
  final bool timedOut;

  /// Whether the face was lost during evaluation.
  final bool faceLost;

  /// Whether multiple faces were detected.
  final bool multipleFaces;

  /// Whether the full target path completed.
  final bool pathCompleted;

  /// Whether the full target path failed.
  final bool pathFailed;

  /// Optional short guidance hint for hosts (`left`, `right`, `up`, `down`).
  final String? guidanceHint;

  @override
  List<Object?> get props => [
        targetId,
        inside,
        distanceToCenter,
        requiredRadius,
        heldFor,
        completed,
        timedOut,
        faceLost,
        multipleFaces,
        pathCompleted,
        pathFailed,
        guidanceHint,
      ];
}

import 'dart:math';

import '../config/face_action_config.dart';
import 'target_zone.dart';

/// Factory for predefined and randomized face-center target paths.
///
/// Paths describe on-screen zones for guided head/face movement — not eye tracking.
class TargetPathFactory {
  /// Creates a target path factory.
  const TargetPathFactory();

  /// Center → left → right → center.
  List<TargetZone> simpleCross({
    FaceActionConfig config = const FaceActionConfig(),
  }) {
    final r = config.targetZoneDefaultRadius;
    final hold = config.targetHoldDuration;
    final timeout = config.targetTimeout;
    return <TargetZone>[
      TargetZone(
        id: 'center',
        centerX: 0.5,
        centerY: 0.5,
        radius: r,
        holdDuration: hold,
        timeout: timeout,
        instruction: 'Center your face on the dot.',
      ),
      TargetZone(
        id: 'left',
        centerX: 0.28,
        centerY: 0.5,
        radius: r,
        holdDuration: hold,
        timeout: timeout,
        instruction: 'Move your face toward the left target.',
      ),
      TargetZone(
        id: 'right',
        centerX: 0.72,
        centerY: 0.5,
        radius: r,
        holdDuration: hold,
        timeout: timeout,
        instruction: 'Move your face toward the right target.',
      ),
      TargetZone(
        id: 'center-return',
        centerX: 0.5,
        centerY: 0.5,
        radius: r,
        holdDuration: hold,
        timeout: timeout,
        instruction: 'Return your face to the center dot.',
      ),
    ];
  }

  /// Center → corners → center.
  List<TargetZone> corners({
    FaceActionConfig config = const FaceActionConfig(),
  }) {
    final r = config.targetZoneDefaultRadius;
    final hold = config.targetHoldDuration;
    final timeout = config.targetTimeout;
    return <TargetZone>[
      TargetZone(
        id: 'center',
        centerX: 0.5,
        centerY: 0.5,
        radius: r,
        holdDuration: hold,
        timeout: timeout,
        instruction: 'Center your face on the dot.',
      ),
      TargetZone(
        id: 'topLeft',
        centerX: 0.28,
        centerY: 0.28,
        radius: r,
        holdDuration: hold,
        timeout: timeout,
        instruction: 'Move your face toward the top-left target.',
      ),
      TargetZone(
        id: 'topRight',
        centerX: 0.72,
        centerY: 0.28,
        radius: r,
        holdDuration: hold,
        timeout: timeout,
        instruction: 'Move your face toward the top-right target.',
      ),
      TargetZone(
        id: 'bottomRight',
        centerX: 0.72,
        centerY: 0.72,
        radius: r,
        holdDuration: hold,
        timeout: timeout,
        instruction: 'Move your face toward the bottom-right target.',
      ),
      TargetZone(
        id: 'bottomLeft',
        centerX: 0.28,
        centerY: 0.72,
        radius: r,
        holdDuration: hold,
        timeout: timeout,
        instruction: 'Move your face toward the bottom-left target.',
      ),
      TargetZone(
        id: 'center-return',
        centerX: 0.5,
        centerY: 0.5,
        radius: r,
        holdDuration: hold,
        timeout: timeout,
        instruction: 'Return your face to the center dot.',
      ),
    ];
  }

  /// Fewer, larger zones for lower-end devices.
  List<TargetZone> lowEndFriendly({
    FaceActionConfig config = const FaceActionConfig(),
  }) {
    final r = max(config.targetZoneDefaultRadius, 0.20);
    final hold = config.targetHoldDuration;
    final timeout = config.targetTimeout;
    return <TargetZone>[
      TargetZone(
        id: 'center',
        centerX: 0.5,
        centerY: 0.5,
        radius: r,
        holdDuration: hold,
        timeout: timeout,
        instruction: 'Center your face on the dot.',
      ),
      TargetZone(
        id: 'left',
        centerX: 0.30,
        centerY: 0.5,
        radius: r,
        holdDuration: hold,
        timeout: timeout,
        instruction: 'Move your face toward the left target.',
      ),
      TargetZone(
        id: 'right',
        centerX: 0.70,
        centerY: 0.5,
        radius: r,
        holdDuration: hold,
        timeout: timeout,
        instruction: 'Move your face toward the right target.',
      ),
      TargetZone(
        id: 'center-return',
        centerX: 0.5,
        centerY: 0.5,
        radius: r,
        holdDuration: hold,
        timeout: timeout,
        instruction: 'Return your face to the center dot.',
      ),
    ];
  }

  /// Deterministic randomized path from [seed].
  List<TargetZone> randomized({
    required int seed,
    FaceActionConfig config = const FaceActionConfig(),
    int maxSteps = 5,
    bool requireCenterFirst = true,
  }) {
    final pool = <TargetZone>[
      ...simpleCross(config: config).where((z) => z.id != 'center-return'),
      TargetZone(
        id: 'top',
        centerX: 0.5,
        centerY: 0.28,
        radius: config.targetZoneDefaultRadius,
        holdDuration: config.targetHoldDuration,
        timeout: config.targetTimeout,
        instruction: 'Move your face toward the top target.',
      ),
      TargetZone(
        id: 'bottom',
        centerX: 0.5,
        centerY: 0.72,
        radius: config.targetZoneDefaultRadius,
        holdDuration: config.targetHoldDuration,
        timeout: config.targetTimeout,
        instruction: 'Move your face toward the bottom target.',
      ),
    ];

    final random = Random(seed);
    final selected = <TargetZone>[];
    if (requireCenterFirst) {
      selected.add(
        TargetZone(
          id: 'center',
          centerX: 0.5,
          centerY: 0.5,
          radius: config.targetZoneDefaultRadius,
          holdDuration: config.targetHoldDuration,
          timeout: config.targetTimeout,
          instruction: 'Center your face on the dot.',
        ),
      );
    }

    final shuffled = List<TargetZone>.from(pool)..shuffle(random);
    for (final zone in shuffled) {
      if (selected.length >= maxSteps) {
        break;
      }
      if (selected.any((z) => z.id == zone.id)) {
        continue;
      }
      selected.add(zone);
    }
    return selected;
  }
}

/// Convenience presets for host apps and demos.
class DefaultTargetPaths {
  const DefaultTargetPaths._();

  /// See [TargetPathFactory.simpleCross].
  static List<TargetZone> simpleCross({
    FaceActionConfig config = const FaceActionConfig(),
  }) =>
      const TargetPathFactory().simpleCross(config: config);

  /// See [TargetPathFactory.corners].
  static List<TargetZone> corners({
    FaceActionConfig config = const FaceActionConfig(),
  }) =>
      const TargetPathFactory().corners(config: config);

  /// See [TargetPathFactory.lowEndFriendly].
  static List<TargetZone> lowEndFriendly({
    FaceActionConfig config = const FaceActionConfig(),
  }) =>
      const TargetPathFactory().lowEndFriendly(config: config);

  /// See [TargetPathFactory.randomized].
  static List<TargetZone> randomized({
    required int seed,
    FaceActionConfig config = const FaceActionConfig(),
    int maxSteps = 5,
  }) =>
      const TargetPathFactory().randomized(
        seed: seed,
        config: config,
        maxSteps: maxSteps,
      );
}

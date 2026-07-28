import 'package:equatable/equatable.dart';

/// Normalized on-screen target zone for face-center tracking challenges.
///
/// Coordinates are in `[0.0, 1.0]` relative to the image / preview plane.
/// This is **not** eye tracking or gaze estimation.
class TargetZone extends Equatable {
  /// Creates a normalized target zone.
  const TargetZone({
    required this.id,
    required this.centerX,
    required this.centerY,
    this.radius = 0.14,
    this.holdDuration = const Duration(milliseconds: 450),
    this.timeout = const Duration(seconds: 8),
    this.instruction = 'Move your face toward the target.',
  });

  /// Stable identifier for audit / UI.
  final String id;

  /// Normalized horizontal center (`0` left, `1` right).
  final double centerX;

  /// Normalized vertical center (`0` top, `1` bottom).
  final double centerY;

  /// Normalized acceptance radius around the center.
  final double radius;

  /// How long the face center must remain inside the zone.
  final Duration holdDuration;

  /// Maximum time allowed to complete this zone after it becomes active.
  final Duration timeout;

  /// Default English instruction for hosts / localization keys.
  final String instruction;

  /// Returns a copy with selectively overridden fields.
  TargetZone copyWith({
    String? id,
    double? centerX,
    double? centerY,
    double? radius,
    Duration? holdDuration,
    Duration? timeout,
    String? instruction,
  }) {
    return TargetZone(
      id: id ?? this.id,
      centerX: centerX ?? this.centerX,
      centerY: centerY ?? this.centerY,
      radius: radius ?? this.radius,
      holdDuration: holdDuration ?? this.holdDuration,
      timeout: timeout ?? this.timeout,
      instruction: instruction ?? this.instruction,
    );
  }

  @override
  List<Object?> get props =>
      [id, centerX, centerY, radius, holdDuration, timeout, instruction];
}

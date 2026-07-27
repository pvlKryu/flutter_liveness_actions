import 'package:equatable/equatable.dart';

/// processing diagnostics.
class ProcessingDiagnostics extends Equatable {
  /// Creates an instance with optional overrides.
  const ProcessingDiagnostics({
    required this.processedFrames,
    required this.droppedFrames,
    required this.averageProcessingMs,
  });

  /// processed frames.
  final int processedFrames;

  /// dropped frames.
  final int droppedFrames;

  /// average processing ms.
  final double averageProcessingMs;

  @override

  /// props.
  List<Object?> get props =>
      [processedFrames, droppedFrames, averageProcessingMs];
}

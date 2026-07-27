/// App / session lifecycle states for liveness-aware processing sessions.
enum LivenessSessionLifecycleState {
  /// Session is active and may process frames.
  active,

  /// Session is paused (app backgrounded or camera stopped).
  paused,

  /// Session resources were disposed.
  disposed,
}

/// Tracks pause / resume / dispose for challenge and frame processing sessions.
///
/// Core package logic stays widget-free. Apps should call these hooks from
/// Flutter `AppLifecycleState` handlers and dispose paths.
class LivenessSessionLifecycle {
  /// Creates a lifecycle tracker in the [active] state.
  LivenessSessionLifecycle() : _state = LivenessSessionLifecycleState.active;

  LivenessSessionLifecycleState _state;
  final List<void Function(LivenessSessionLifecycleState)> _listeners =
      <void Function(LivenessSessionLifecycleState)>[];

  /// Current lifecycle state.
  LivenessSessionLifecycleState get state => _state;

  /// Whether frames may be processed.
  bool get isActive => _state == LivenessSessionLifecycleState.active;

  /// Registers a state-change [listener].
  void addListener(void Function(LivenessSessionLifecycleState) listener) {
    _listeners.add(listener);
  }

  /// Removes a previously registered [listener].
  void removeListener(void Function(LivenessSessionLifecycleState) listener) {
    _listeners.remove(listener);
  }

  /// Marks the session active / resumed.
  void resume() {
    if (_state == LivenessSessionLifecycleState.disposed) {
      return;
    }
    _set(LivenessSessionLifecycleState.active);
  }

  /// Marks the session paused.
  void pause() {
    if (_state == LivenessSessionLifecycleState.disposed) {
      return;
    }
    _set(LivenessSessionLifecycleState.paused);
  }

  /// Marks the session disposed. Further pause/resume calls are ignored.
  void dispose() {
    _set(LivenessSessionLifecycleState.disposed);
    _listeners.clear();
  }

  void _set(LivenessSessionLifecycleState next) {
    if (_state == next) {
      return;
    }
    _state = next;
    for (final listener in List.of(_listeners)) {
      listener(next);
    }
  }
}

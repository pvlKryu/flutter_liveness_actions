/// hysteresis threshold.
class HysteresisThreshold {
  /// Creates on/off thresholds for boolean signal stabilization.
  HysteresisThreshold({
    required this.onThreshold,
    required this.offThreshold,
    this.initialState = false,
  }) : _state = initialState;

  /// on threshold.
  final double onThreshold;

  /// off threshold.
  final double offThreshold;

  /// initial state.
  final bool initialState;
  bool _state;

  /// apply.
  bool apply(double value) {
    if (_state) {
      if (value < offThreshold) {
        _state = false;
      }
    } else if (value > onThreshold) {
      _state = true;
    }
    return _state;
  }

  /// reset.
  void reset() {
    _state = initialState;
  }
}

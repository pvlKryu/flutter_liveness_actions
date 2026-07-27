import 'dart:collection';

/// temporal signal buffer.
class TemporalSignalBuffer {
  /// temporal signal buffer.
  TemporalSignalBuffer({required this.maxSize}) : assert(maxSize > 0);

  /// max size.
  final int maxSize;

  ///  values.
  final Queue<double> _values = Queue<double>();
  double _sum = 0;

  /// add.
  void add(double value) {
    _values.addLast(value);
    _sum += value;
    if (_values.length > maxSize) {
      _sum -= _values.removeFirst();
    }
  }

  /// average.
  double get average => _values.isEmpty ? 0 : _sum / _values.length;

  /// is empty.
  bool get isEmpty => _values.isEmpty;

  /// clear.
  void clear() {
    _values.clear();
    _sum = 0;
  }
}

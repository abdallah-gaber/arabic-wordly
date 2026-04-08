import 'dart:math';

/// [Random] that always returns `_value % max` from [nextInt].
class FixedRandom implements Random {
  FixedRandom(this._value);

  final int _value;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) => _value % max;
}

/// [Random] that cycles through a fixed sequence for [nextInt].
class FixedSequenceRandom implements Random {
  FixedSequenceRandom(this._values);

  final List<int> _values;
  int _index = 0;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;

  @override
  int nextInt(int max) {
    final value = _values[_index % _values.length] % max;
    _index += 1;
    return value;
  }
}

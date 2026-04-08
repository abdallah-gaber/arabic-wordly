/// Mutable [DateTime] source for overriding [clockProvider] in tests.
class MutableClock {
  MutableClock(this._now);

  DateTime _now;

  DateTime call() => _now;

  set value(DateTime v) => _now = v;
}

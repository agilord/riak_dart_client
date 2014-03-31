// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of metrics;

abstract class Counter extends Metric {

  factory Counter({Duration window, int frameCount: 20}) =>
      window == null
          ? new _Counter()
          : new _DecayingCounter(window, math.max(4, frameCount));

  void trackValue(num value);

  int get count;
  num get min;
  num get avg;
  num get max;
}

class _Counter implements Counter {

  int _count = 0;
  num _sum = 0;
  num _min;
  num _max;

  _Counter() : super();

  trackValue(num value) {
    _sum += value;
    _count++;
    _min = _min == null ? value : math.min(_min, value);
    _max = _max == null ? value : math.max(_max, value);
  }

  int get count => _count;
  num get min => _min;
  num get avg => _count == 0 ? null : (_sum / _count);
  num get max => _max;

  @override
  void writeValues(String name, Map<String, num> map) {
    map['$name.count'] = count;
    map['$name.avg'] = avg;
    map['$name.min'] = min;
    map['$name.max'] = max;
  }
}

class _DecayingCounter implements Counter {
  final Duration period;

  DateTime _lastTick;

  Duration _frameDuration;
  Queue<_CounterFrame> _frames = new DoubleLinkedQueue();

  _DecayingCounter(this.period, int frameCount) {
    _frameDuration =
        new Duration(microseconds: period.inMicroseconds ~/ frameCount);
  }

  trackValue(num value) {
    DateTime now = _tick();
    bool create = _frames.isEmpty || now.isAfter(_frames.last.validUntil);
    if (create) {
      var end = now.add(period);
      _frames.add(new _CounterFrame(
          now.add(_frameDuration), end, end.add(_frameDuration)));
    }
    _frames.last.trackValue(value);
  }

  @override
  void writeValues(String name, Map<String, num> map) {
    map['$name.count'] = count;
    map['$name.avg'] = avg;
    map['$name.min'] = min;
    map['$name.max'] = max;
  }

  int get count {
    _tick();
    num cnt = _frames.fold(0, (num c, frame) => c + frame.count);
    return cnt.toInt();
  }

  num get avg {
    _tick();
    num cnt = _frames.fold(0, (num c, frame) => c + frame.count);
    if (cnt == 0) {
      return null;
    }
    num sum = _frames.fold(0, (num s, frame) => s + frame.sum);
    return sum / cnt;
  }

  num get min {
    _tick();
    return _frames.fold(null, (num v, frame) => frame.minValue(v));
  }

  num get max {
    _tick();
    return _frames.fold(null, (num v, frame) => frame.maxValue(v));
  }

  DateTime _tick() {
    DateTime now = metrics_now();
    if (_lastTick != null && now.difference(_lastTick).inSeconds < 1) {
      return now;
    }
    while (_frames.isNotEmpty && _frames.first.removeAt.isBefore(now)) {
      _frames.removeFirst();
    }
    if (_frames.isNotEmpty && _frames.first.endedAt.isBefore(now)) {
      _frames.first.decay(now, _frameDuration);
    }
    _lastTick = now;
    return now;
  }
}

class _CounterFrame {
  final DateTime validUntil; // don't increment count after this point
  final DateTime endedAt;    // interpolate value after this point
  final DateTime removeAt;   // remove frame after this point

  num _preDecayCount;
  num _preDecaySum;

  num count = 0;
  num sum = 0;
  num min;
  num max;

  _CounterFrame(this.validUntil, this.endedAt, this.removeAt);

  trackValue(num value) {
    count ++;
    sum += value;
    min = min == null ? value : math.min(min, value);
    max = max == null ? value : math.max(max, value);
  }

  decay(DateTime now, Duration length) {
    min = null;
    max = null;

    Duration diff = now.difference(endedAt);
    if (_preDecayCount == null) {
      _preDecayCount = count;
      _preDecaySum = sum;
    }
    double rate = 1 - (diff.inMicroseconds / length.inMicroseconds);
    count = _preDecayCount * rate;
    sum = _preDecaySum * rate;
  }

  num minValue(num v) {
    if (min == null) {
      return v;
    }
    if (v == null) {
      return min;
    }
    return math.min(v,  min);
  }

  num maxValue(num v) {
    if (max == null) {
      return v;
    }
    if (v == null) {
      return max;
    }
    return math.max(v,  max);
  }
}

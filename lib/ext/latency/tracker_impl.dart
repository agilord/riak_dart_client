// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of latency;

/**
 * A counter that tracks event times over the last minute, hour or day.
 */
class _Tracker extends _DurationSink implements Tracker {

  _PeriodTracker _minute;
  _PeriodTracker _hour;
  _PeriodTracker _day;

  _Tracker(String event, bool quantiles,
          {TimeSource timeSource, Random random}) {
    _minute = new _PeriodTracker(event, Period.MINUTE,
        new Duration(minutes: 1), quantiles, frames: 12, // 5-second frames
         timeSource: timeSource, random: random);
    _hour = new _PeriodTracker(event, Period.HOUR,
        new Duration(hours: 1), quantiles, frames: 12, // 5-minute frames
        timeSource: timeSource, random: random);
    _day = new _PeriodTracker(event, Period.DAY,
        new Duration(days: 1), quantiles, frames: 24, // 1-hour frames
        timeSource: timeSource, random: random);
  }

  void add(Duration event) {
    _minute.add(event);
    _hour.add(event);
    _day.add(event);
  }

  Latency get minute => _minute.stats;
  Latency get hour => _hour.stats;
  Latency get day => _day.stats;

  Iterable<Latency> get stats => [minute, hour, day];
}

/**
 * A counter that tracks values over a predefined period.
 *
 * It uses reservoir sampling [1] and rolling time frames to compress the stats,
 * allowing a memory bound to be made over the sample size.
 *
 * When a frame goes out of boundary, it will get removed from the counter.
 * When a frame is on the boundary, count is determined by linear interpolation.
 *
 * [1] http://en.wikipedia.org/wiki/Reservoir_sampling
 */
class _PeriodTracker extends _DurationSink {
  final String event;
  final String periodName;
  final Duration period;
  final bool quantiles;

  TimeSource _timeSource;
  Random _random;
  Duration _frame;
  int _sampleSize;
  List _frames = new List();

  _PeriodTracker(String this.event,
                 String this.periodName,
                 Duration this.period,
                 bool this.quantiles,
                {int frames: 10,
                 int samplePerFrame: 100,
                 TimeSource timeSource,
                 Random random}) {
    assert(period != null);
    assert(period.inSeconds > 0);
    assert(frames > 0);
    assert(samplePerFrame >= 10);
    _timeSource = timeSource == null ? new TimeSource() : timeSource;
    _frame = new Duration(milliseconds: period.inMilliseconds ~/ frames);
    _sampleSize = samplePerFrame;
    _random = random == null ?
        new Random(_timeSource.now().millisecondsSinceEpoch) : random;
  }

  void add(Duration value) {
    DateTime now = _timeSource.now();
    _Frame f;
    if (_frames.isEmpty) {
      f = new _Frame(now);
      _frames.add(f);
    } else {
      f = _frames.first;
      if (f.start.difference(now).inMilliseconds > _frame.inMilliseconds) {
        f.close(now);
        f = new _Frame(now);
        _frames.insert(0, f);
      }
    }

    bool sample = false;
    int index;
    if (quantiles) {
      if (f._buffer.length < _sampleSize) {
        sample = true;
      } else {
        int index = _random.nextInt(f._count);
        if (index < _sampleSize) {
          sample = true;
        }
      }
    }
    f.add(value.inMicroseconds, sample, index);

    var last = _frames.last;
    if (last._end != null &&
        last._end.difference(now).inMilliseconds > period.inMilliseconds) {
      _frames.remove(last);
    }
  }

  Latency get stats {
    DateTime ts = _timeSource.now();

    List<int> sample = [];
    double sum = 0.0;
    double cnt = 0.0;
    int minv;
    int maxv;
    _frames.forEach((_Frame f) {
      double w = f.getWeight(ts);
      sum += f._sum * w;
      cnt += f._count * w;

      var s = f.getSample(w);
      sample.addAll(s);

      int mins;
      int maxs;
      if (w == 1.0) {
        mins = f._min;
        maxs = f._max;
      } else if (w > 0.0 && s.isNotEmpty) {
        s.sort();
        mins = s.first;
        maxs = s.last;
      }
      if (mins != null) {
        minv = minv == null ? mins : min(mins, minv);
        maxv = maxv == null ? maxs : max(maxs, maxv);
      }
    });
    sample.sort();
    int avg = cnt > 0 ? sum ~/ cnt : null;
    double load = sum / period.inMicroseconds;
    return new Latency(event, periodName, _timeSource.now(),
        cnt.floor(),
        load,
        _toDuration(minv),
        _toDuration(avg),
        _toDuration(maxv),
        quantiles ? _toQuantiles(sample) : null);
  }

  Quantiles _toQuantiles(List<int> sample) {
    List<Duration> list = [];
    for (int i = 0; i <= 99; i++) {
      list.add(_toDuration(_quantile(sample, i / 100)));
    }
    Duration p999 = _toDuration(_quantile(sample, 0.999));
    return new Quantiles(list, p999);
  }

  int _quantile(List<int> sample, double p) =>
      sample.isEmpty ? null : sample[(p * sample.length).floor()];

  _toDuration(int value) =>
      value == null ? null : new Duration(microseconds: value);
}

class _Frame {
  static final List _EMPTY = new UnmodifiableListView([]);
  final DateTime start;

  DateTime _end;
  int _count = 0;
  List<int> _buffer = [];

  int _min;
  int _max;
  int _sum = 0;

  _Frame(this.start) {
    assert(start != null);
  }

  void add(int value, bool sample, int index) {
    assert(_end == null);
    _count ++;
    _sum += value;
    _min = _min == null ? value : min(value, _min);
    _max = _max == null ? value : max(value, _max);
    if (sample) {
      if (index == null) {
        _buffer.add(value);
      } else {
        _buffer[index] = value;
      }
    }
  }

  List<int> getSample(double w) {
    if (w == 0.0) {
      return _EMPTY;
    } else if (w == 1.0) {
      return _buffer;
    } else {
      return _buffer.sublist(0, (_buffer.length * w).floor());
    }
  }

  double getWeight(DateTime ts) {
    if (ts.isBefore(start)) {
      return 0.0;
    }
    if (_end == null) {
      return 1.0;
    }
    if (ts.isAfter(_end)) {
      return 0.0;
    }
    Duration diff = ts.difference(start);
    Duration total = _end.difference(start);
    return diff.inMilliseconds / total.inMilliseconds;
  }

  void close(DateTime now) {
    _end = now;
  }
}

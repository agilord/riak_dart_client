// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of metrics;

abstract class Reservoir extends Counter {

  factory Reservoir({int limit: 256,
                     Duration window,
                     bool timeBiased: false,
                     math.Random random}) {
    if (window == null) {
      return new _Reservoir(limit, random);
    } else {
      if (timeBiased) {
        return new _DecayingQueueReservoir(limit, window, random);
      } else {
        return new _DecayingListReservoir(limit, window, random);
      }
    }
  }

  List<num> getSample();
  num getQuantile(double q);

  num get q50;
  num get q75;
  num get q90;
  num get q99;
}

abstract class _ReservoirBase implements Reservoir {

  final int limit;
  final Counter _counter;
  math.Random _random;

  List<num> _sample;

  _ReservoirBase(this.limit, this._counter, this._random) {
    if (_random == null) {
      _random = new math.Random();
    }
  }

  int get count => _counter.count;
  num get avg => _counter.avg;
  num get min => _counter.min;
  num get max => _counter.max;

  num get q50 => getQuantile(0.50);
  num get q75 => getQuantile(0.75);
  num get q90 => getQuantile(0.90);
  num get q99 => getQuantile(0.99);

  num getQuantile(double q) {
    List sample = getSample();
    if (sample.isEmpty) {
      return null;
    }
    return sample[(sample.length * q).floor()];
  }

  int _nextIndex() =>
      _random.nextInt(count);

  _markDirty() {
    _sample = null;
  }

  @override
  void writeValues(String name, Map<String, num> map) {
    _counter.writeValues(name, map);
    map['$name.q50'] = q50;
    map['$name.q75'] = q75;
    map['$name.q90'] = q90;
    map['$name.q99'] = q99;
  }

  @override
  List<num> getSample() {
    if (_sample == null) {
      _sample = _createSample();
    }
    return _sample;
  }

  List<num> _createSample();
}

class _Reservoir extends _ReservoirBase {

  List<num> _buffer = [];
  _Reservoir(int limit, math.Random random)
      : super(limit, new Counter(), random);

  @override
  void trackValue(num value) {
    _markDirty();
    if (_buffer.length < limit) {
      _buffer.add(value);
    } else {
      int index = _nextIndex();
      if (index < _buffer.length) {
        _buffer[index] = value;
      }
    }
    _counter.trackValue(value);
  }

  @override
  _createSample() =>
    new UnmodifiableListView(new List.from(_buffer)..sort());
}


class _DecayingListReservoir extends _ReservoirBase {

  List<num> _buffer = [];
  _DecayingListReservoir(int limit, Duration window, math.Random random)
      : super(limit, new Counter(window: window), random);

  void trackValue(num value) {
    _markDirty();
    _shrinkBuffer();
    if (_buffer.length < limit) {
      _buffer.add(value);
    } else {
      int index = _nextIndex();
      if (index < _buffer.length) {
        _buffer[index] = value;
      }
    }
    _counter.trackValue(value);
  }

  void _shrinkBuffer() {
    if (count < _buffer.length) {
      _buffer = _buffer.sublist(_buffer.length - count);
    }
  }

  _createSample() {
    _shrinkBuffer();
    return new UnmodifiableListView(new List.from(_buffer)..sort());
  }
}

class _DecayingQueueReservoir extends _ReservoirBase {

  Queue<num> _queue;
  _DecayingQueueReservoir(int limit, Duration window, math.Random random)
      : super(limit, new Counter(window: window), random) {
    _queue = new ListQueue(limit);
  }

  void trackValue(num value) {
    _markDirty();
    _shrinkBuffer();
    if (_queue.length < limit) {
      _queue.add(value);
    } else {
      int index = _nextIndex();
      if (index < limit) {
        _queue.removeFirst(); //
        _queue.add(value);
      }
    }
    _counter.trackValue(value);
  }

  void _shrinkBuffer() {
    int take = _queue.length - count;
    while (take > 0) {
      _queue.removeFirst();
      take--;
    }
  }

  _createSample() {
    _shrinkBuffer();
    return new UnmodifiableListView(new List.from(_queue)..sort());
  }
}


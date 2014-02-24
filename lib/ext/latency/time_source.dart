// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of latency;

/** Provides the current time, making it easily testable. */
abstract class TimeSource {

  DateTime now();

  factory TimeSource() =>
      new _TimeSource();
}

class _TimeSource implements TimeSource {

  DateTime now() =>
      new DateTime.now();
}

/** Freezes time and allows time forwards for testing. */
class MockTimeSource implements TimeSource {

  DateTime _now;

  MockTimeSource([DateTime this._now]) {
    if (_now == null) {
      _now = new DateTime.now();
    }
  }

  DateTime now() => _now;

  void forward(Duration duration) {
    _now = _now.add(duration);
  }
}

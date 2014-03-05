// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library retryer;

import 'dart:async';
import 'dart:math';

typedef void Retryable<T>(Completer<T> completer);

abstract class Retryer<T> {

  // subject to change
  factory Retryer(Retryable<T> retryable) =>
      new _Retryer(retryable, sleep: new Duration(milliseconds: 5));

  bool get wasSuccess;

  Future<T> get future;
}

class _Retryer<T> implements Retryer {
  final Retryable<T> retryable;
  int _limit;
  Duration _sleep;
  Duration _maxSleep;
  bool _linearBackoff;
  bool _expBackoff;

  int _tries;
  bool _wasSuccess;

  Completer _result = new Completer();

  Object _lastError;
  StackTrace _lastStackTrace;

  _Retryer(Retryable<T> this.retryable,
          {int limit: 3,
           Duration sleep: Duration.ZERO,
           Duration maxSleep,
           bool linearBackoff: false,
           bool expBackoff: false})
      : _limit = limit,
        _sleep = sleep,
        _maxSleep = maxSleep,
        _linearBackoff = linearBackoff,
        _expBackoff = expBackoff {
    _tries = 0;
    _schedule();
  }

  bool get wasSuccess => _wasSuccess;
  Future<T> get future => _result.future;

  _schedule() {
    if (_result.isCompleted) {
      return;
    }
    if (_limit <= _tries) {
      _wasSuccess = false;
      _result.completeError("max tries have reached: $_tries, with error: $_lastError", _lastStackTrace);
      return;
    }
    _tries++;
    int multiplier = 0;
    if (_tries > 1) {
      if (_expBackoff) {
        multiplier = pow(2, (_tries - 2));
      } else if (_linearBackoff) {
        multiplier = (_tries - 1);
      } else {
        multiplier = 1;
      }
    }
    int waitMillis = multiplier * _sleep.inMilliseconds;
    if (_maxSleep != null) {
      waitMillis = min(waitMillis, _maxSleep.inMilliseconds);
    }
    new Timer(new Duration(milliseconds: waitMillis), () {
      Completer c = new Completer();
      c.future.then((v) {
        _result.complete(v);
        _wasSuccess = true;
      }, onError: (e, st) {
        _lastError = e;
        _lastStackTrace = st;
        _schedule();
      });
      retryable(c);
    });
  }
}

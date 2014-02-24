// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of latency;

/**
 * Base class handling the [Stream] of [Duration]s and [Future]s.
 */
abstract class _DurationSink implements StreamSink<Duration> {
  Completer _doneCompleter = new Completer();
  Future _doneFuture;
  Set<StreamSubscription> _streams = new Set();

  _DurationSink() {
    _doneFuture = _doneCompleter.future;
  }

  bool get _isDone =>
      _doneCompleter == null;

  void addError(errorEvent, [StackTrace stackTrace]) {
  }

  Future addStream(Stream<Duration> stream) {
    if (_isDone) {
      throw "Sink already closed.";
    }
    var c = new Completer();
    StreamSubscription s = stream.listen((Duration v) {
      add(v);
    }, onDone: () {
      c.complete();
      _streams.remove(c);
    });
    _streams.add(s);
    return c.future;
  }

  Future close() {
    if (_isDone) {
      return new Future.value();
    }
    List<Future> fs = [];
    _doneCompleter.complete();
    _doneCompleter = null;
    _streams.forEach((s) { fs.add(s.cancel()); });
    _streams = null;
    return Future.wait(fs);
  }

  Future get done =>
      _doneFuture;
}


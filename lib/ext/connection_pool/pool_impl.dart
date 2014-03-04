// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of connection_pool;

class _Pool<T> implements ConnectionPool<T> {
  final String name;
  final _Factory _factory;

  TimeSource _timeSource = new TimeSource();
  Duration idleTimeout = new Duration(minutes: 1);
  Duration connectTimeout = new Duration(milliseconds: 1500);
  int maxPoolSize = 5;

  Tracker _openSuccess;
  Tracker _openTimeout;
  bool _isClosed = false;

  Queue<_IdleConnection<T>> _idleConnections = new ListQueue();
  Set<_ActiveConnection<T>> _activeConnections = new Set();
  Queue<_WaitingToBeConnected> _waitingToBeConnected = new ListQueue();
  Set<_OpenInProgress> _openInProgress = new Set();

  _Cluster _cluster;

  _Pool(String this.name, _Factory this._factory) {
    _openSuccess = new Tracker("$name/open-success");
    _openTimeout = new Tracker("$name/open-timeout");
    _cluster = new _Cluster(name);
  }

  int get count =>
      _idleConnections.length +
      _activeConnections.length +
      _openInProgress.length;

  join(Endpoint endpoint) =>
      _cluster.join(endpoint);

  // TODO: close idles
  // TODO: cancel open in progress
  leave(Endpoint endpoint) =>
      _cluster.leave(endpoint);

  _IdleConnection _pickIdle() {
    while (_idleConnections.isNotEmpty) {
      var ic = _idleConnections.removeFirst();
      Duration diff = ic.idleTime.difference(_timeSource.now());
      if (!_isClosed && diff.inMicroseconds < idleTimeout.inMicroseconds) {
        ic.endpoint.idleWait.add(diff);
        return ic;
      } else {
        ic.endpoint.idleClose.add(diff);
        _factory.close(ic.connection);
      }
    }
    return null;
  }

  Connection<T> _activateCompleter(_Endpoint endpoint, T conn) {
    if (_isClosed) {
      throw "pool is closed.";
    }
    Completer c = new Completer();
    var ac = new _ActiveConnection(endpoint, conn, _timeSource.now(), c);
    _activeConnections.add(ac);
    ac.returnFuture.then((_) {
      Duration diff = ac.activationTime.difference(_timeSource.now());
      endpoint.useSuccess.add(diff);
      _queue(endpoint, conn);
    }, onError: (e, st) {
      Duration diff = ac.activationTime.difference(_timeSource.now());
      endpoint.useError.add(diff);
      _queue(endpoint, conn, true);
    }).whenComplete(() {
      _activeConnections.remove(ac);
    });
    return new Connection(endpoint.endpoint, conn, c);
  }

  _queue(_Endpoint endpoint, T conn, [bool error = false]) {
    if (error || endpoint._isClosed || _isClosed) {
      _factory.close(conn);
      _connectIfRequired();
      return;
    }
    while (_waitingToBeConnected.isNotEmpty) {
      var wtbc = _waitingToBeConnected.removeFirst();
      if (wtbc.completer.isCompleted) {
        continue;
      }
      _openSuccess.add(_timeSource.now().difference(wtbc.waitStarted));
      wtbc.completer.complete(_activateCompleter(endpoint, conn));
      return;
    }
    _idleConnections.add(new _IdleConnection(endpoint, conn, _timeSource.now()));
  }

  Future<Connection<T>> open() {
    if (_isClosed) {
      throw "pool is closed";
    }

    _IdleConnection ic = _pickIdle();
    if (ic != null) {
      return new Future.value(_activateCompleter(ic.endpoint, ic.connection));
    }

    var c = new Completer();
    var wtbc = new _WaitingToBeConnected(_timeSource.now(), c);
    _waitingToBeConnected.add(wtbc);
    _connectIfRequired();
    new Timer(connectTimeout, () {
      if (wtbc.completer.isCompleted) {
        return;
      }
      _waitingToBeConnected.remove(wtbc);
      wtbc.completer.completeError("timeout");
      _openTimeout.add(_timeSource.now().difference(wtbc.waitStarted));
    });
    return c.future;
  }

  Future close() {
    _isClosed = true;
    _pickIdle(); // drains idle queue
    _waitingToBeConnected.forEach((w) {
      _openTimeout.add(w.waitStarted.difference(_timeSource.now()));
      w.completer.completeError("close");
    });
    _waitingToBeConnected.clear();

    _openInProgress.forEach((p) {
      p.completer.completeError("close");
    });
    _openInProgress.clear();

    List fs = [];
    fs.addAll(_activeConnections.map((ac) => ac.returnFuture));
    if (fs.isEmpty) {
      return new Future.value();
    } else {
      return Future.wait(fs);
    }
  }

  _connectIfRequired() {
    while (_waitingToBeConnected.isNotEmpty &&
           _waitingToBeConnected.length > _openInProgress.length &&
           count < maxPoolSize) {
      Completer<T> c = new Completer();
      _Endpoint endpoint = _cluster._selectEndpoint();
      var oip = new _OpenInProgress(endpoint, _timeSource.now(), c);
      _openInProgress.add(oip);
      c.future.then((conn) {
        endpoint.factorySuccess.add(_timeSource.now().difference(oip.start));
        _queue(endpoint, conn);
      }, onError: (e, st) {
        endpoint.factoryError.add(_timeSource.now().difference(oip.start));
      }).whenComplete(() {
        _openInProgress.remove(oip);
        _connectIfRequired();
      });
      new Timer(connectTimeout, () {
        if (c.isCompleted) {
          return;
        }
        endpoint.factoryTimeout.add(_timeSource.now().difference(oip.start));
        c.completeError("timeout");
      });
      _factory.open(endpoint.endpoint, c);
    }
  }
}

class _IdleConnection<T> {
  final _Endpoint endpoint;
  final T connection;
  final DateTime idleTime;
  _IdleConnection(this.endpoint, this.connection, this.idleTime);
}

class _ActiveConnection<T> {
  final _Endpoint endpoint;
  final T connection;
  final DateTime activationTime;
  final Completer returnCompleter;

  _ActiveConnection(this.endpoint, this.connection, this.activationTime,
                    this.returnCompleter);

  Future get returnFuture =>
      returnCompleter.future;
}

class _WaitingToBeConnected {
  final DateTime waitStarted;
  final Completer completer;
  _WaitingToBeConnected(this.waitStarted, this.completer);
}

class _OpenInProgress {
  final _Endpoint endpoint;
  final DateTime start;
  final Completer completer;
  _OpenInProgress(this.endpoint, this.start, this.completer);
}

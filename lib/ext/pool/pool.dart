// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library pool;

import 'dart:async';
import 'dart:collection';
import 'dart:math';

class PoolEvent<T> {
  static final String ACQUIRE_TIMEOUT = "acquire-timeout";
  static final String FACTORY_CREATE  = "factory-create";
  static final String FACTORY_ERROR   = "factory-timeout";
  static final String IDLE_WAIT       = "idle-wait";
  static final String IDLE_TIMEOUT    = "idle-timeout";
  static final String RELEASE_SUCCESS = "release-success";
  static final String RELEASE_ERROR   = "release-error";

  final T object;
  final String eventType;
  final Duration duration;

  final Object error;
  final StackTrace stackTrace;

  PoolEvent(this.object, this.eventType, this.duration,
           [this.error, this.stackTrace]);

  bool get isError => error != null;
}

abstract class Pool<T> {
  final Expando _timeAttr = new Expando();

  StreamController _events =
      new StreamController.broadcast();

  bool _isClosed = false;

  int _minPooled = 0;
  int _maxPooled = 5;

  Duration _idleTimeout   = new Duration(seconds: 15);
  Duration acquireTimeout = new Duration(seconds:  2);

  Queue<T> _idleObjects = new ListQueue();
  Queue<T> _activeObjects = new ListQueue();
  Queue<_Waiting> _waitingClients = new ListQueue();

  Set<Future<T>> _inCreation = new Set();
  Set<Future<T>> _inDestroy = new Set();

  Pool();

  Future<T> create({ Duration timeout });
  Future destroy(T object);

  int get minPooled => _minPooled;
      set minPooled(int v) { _minPooled = v; _processQueue(); }

  int get maxPooled => _maxPooled;
      set maxPooled(int v) { _maxPooled = v; _processQueue(); }

  Duration get idleTimeout => _idleTimeout;
           set idleTimeout(Duration v) { _idleTimeout = v; _processQueue(); }

  Stream<PoolEvent> get onEvent =>
      _events.stream;

  int get pooledCount =>
      _idleObjects.length + _activeObjects.length + _inCreation.length;

  bool isValid(T object) => true;

  void validate() {
    List toRemove = _idleObjects.where((o) => !isValid(o)).toList();
    toRemove.forEach((o) {
      _idleObjects.remove(o);
      _destroy(o);
    });
  }

  Future<T> acquire({ int priority, Duration timeout, Future releaseOn }) {
    if (_isClosed) {
      throw new StateError("pool is closed");
    }
    if (timeout == null) {
      timeout = acquireTimeout;
    }

    final w = new _Waiting(_now(), priority, releaseOn);
    if (w.priority == null) {
      // no priority: end of queue
      _waitingClients.add(w);
    } else {
      // adding to queue with priority
      Queue queue = new Queue();
      while (_waitingClients.isNotEmpty &&
          _waitingClients.first.priority != null &&
          _waitingClients.first.priority <= w.priority) {
        queue.add(_waitingClients.removeFirst());
      }
      _waitingClients.addFirst(w);
      while (queue.isNotEmpty) {
        _waitingClients.addFirst(queue.removeLast());
      }
    }

    if (timeout != null) {
      new Timer(timeout, () {
        if (w.c.isCompleted) {
          return;
        }
        w.c.completeError(new TimeoutException("acquire timeout", timeout));
        _waitingClients.remove(w);
        processEvent(new PoolEvent(null, PoolEvent.ACQUIRE_TIMEOUT, timeout));
      });
    }

    _processQueue();
    return w.future;
  }

  void release(T object, [Object error, StackTrace stackTrace]) {
    _activeObjects.remove(object);
    Duration diff = _now().difference(_timeAttr[object]);

    String eventName = PoolEvent.RELEASE_SUCCESS;
    if (error == null && isValid(object)) {
      _timeAttr[object] = _now();
      _idleObjects.add(object);
    } else {
      _destroy(object);
      if (error != null) {
        eventName = PoolEvent.RELEASE_ERROR;
      }
    }
    processEvent(new PoolEvent(object, eventName, diff, error, stackTrace));
    _processQueue();
  }

  DateTime _now() =>
      new DateTime.now();

  _processQueue() {
    if (_isClosed) {
      return;
    }
    // size validation
    if (_minPooled == null) {
      _minPooled = 0;
    }
    if (_maxPooled == null) {
      _maxPooled = 1;
    }
    _minPooled = max(0, _minPooled);
    _maxPooled = max(1, _maxPooled);
    _minPooled = min(_minPooled, _maxPooled);

    // flush idle
    while (_waitingClients.isNotEmpty &&
           _idleObjects.isNotEmpty &&
           pooledCount <= maxPooled) {
      T object = _pickIdle();
      if (object != null) {
        _Waiting w = _waitingClients.removeFirst();
        if (w.c.isCompleted) {
          _idleObjects.addFirst(object);
        } else {
          _timeAttr[object] = _now();
          _activeObjects.add(object);
          w.c.complete(object);
          if (w.releaseOn != null) {
            w.releaseOn.then((_) {
              release(object);
            }, onError: (e, st) {
              release(object, e, st);
            });
          }
        }
      }
    }

    // create new objects
    while (pooledCount < maxPooled &&
        (pooledCount < minPooled
            || _inCreation.length < _waitingClients.length)) {
      DateTime start = _now();
      Future f = create(timeout: acquireTimeout);
      _inCreation.add(f);
      f.then((v) {
        Duration diff = _now().difference(start);
        processEvent(new PoolEvent(v, PoolEvent.FACTORY_CREATE, diff));
        if (_isClosed) {
          _destroy(v);
        } else {
          _timeAttr[v] = _now();
          _idleObjects.add(v);
        }
      }, onError: (e, st) {
        Duration diff = _now().difference(start);
        processEvent(new PoolEvent(null, PoolEvent.FACTORY_ERROR, diff, e, st));
      }).whenComplete(() {
        _inCreation.remove(f);
        _processQueue();
      });
    }
  }

  T _pickIdle() {
    while (_idleObjects.isNotEmpty) {
      T object = _idleObjects.removeFirst();
      DateTime idleSince = _timeAttr[object];
      Duration diff = idleSince.difference(_now());
      bool ok = isValid(object) &&
          (idleTimeout == null || idleTimeout.compareTo(diff) >= 0);
      if (ok) {
        processEvent(new PoolEvent(object, PoolEvent.IDLE_WAIT, diff));
        return object;
      } else {
        processEvent(new PoolEvent(object, PoolEvent.IDLE_TIMEOUT, diff));
        _destroy(object);
      }
    }
    return null;
  }

  void _destroy(T object) {
    Future f = destroy(object);
    _inDestroy.add(f);
    f.whenComplete(() {
      _inDestroy.remove(f);
    });
  }

  Future close() {
    _isClosed = true;

    while (_idleObjects.isNotEmpty) {
      var object = _idleObjects.removeFirst();
      _destroy(object);
    }

    while (_waitingClients.isNotEmpty) {
      _waitingClients.removeFirst().c
          .completeError(new StateError("pool is closing"));
    }

    Future f = _inCreation.isEmpty ?
        new Future.value() : Future.wait(new List.from(_inCreation));

    return f.whenComplete(() {
      return _inDestroy.isEmpty ?
          new Future.value() : Future.wait(new List.from(_inDestroy));
    }).whenComplete(() => new Future.value());
  }

  /**
   * Process an event in the pool (publishing it on the onEvent stream).
   *
   * This method is public only for subclasses that want to override event
   * processing or add new events the same way the base class processes them.
   */
  void processEvent(PoolEvent event) {
    _events.add(event);
  }
}

class _Waiting {
  final Completer c = new Completer();
  final DateTime waitStarted;
  final int priority;
  final Future releaseOn;
  _Waiting(this.waitStarted, this.priority, this.releaseOn);

  Future get future => c.future;
}

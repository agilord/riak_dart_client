// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of connection_pool;

class _Endpoint {
  final Endpoint endpoint;

  Tracker _factorySuccess;
  Tracker _factoryTimeout;
  Tracker _factoryError;

  Tracker _idleWait;
  Tracker _idleClose;

  Tracker _useSuccess;
  Tracker _useError;

  bool _isClosed = false;

  _Endpoint(String cluster, this.endpoint) {
    String name = "$cluster/$endpoint";
    _factorySuccess = new Tracker("$name/factory-success");
    _factoryTimeout = new Tracker("$name/factory-timeout");
    _factoryError   = new Tracker("$name/factory-error");
    _idleWait       = new Tracker("$name/idle-wait");
    _idleClose      = new Tracker("$name/idle-close");
    _useSuccess     = new Tracker("$name/use-success");
    _useError       = new Tracker("$name/use-error");
  }

  Tracker get factorySuccess => _factorySuccess;
  Tracker get factoryTimeout => _factoryTimeout;
  Tracker get factoryError => _factoryError;
  Tracker get idleWait => _idleWait;
  Tracker get idleClose => _idleWait;
  Tracker get useSuccess => _useSuccess;
  Tracker get useError => _useError;
}

// TODO: remove endpoints if starts failing
class _Cluster {
  final String name;
  Random _random = new Random();
  List<_Endpoint> _endpoints = [];

  _Cluster(this.name);

  _Endpoint _selectEndpoint() {
    if (_endpoints.isEmpty) {
      throw "no endpoints";
    }
    if (_endpoints.length == 1) {
      return _endpoints.first;
    }
    // TODO: select endpoint based on the error ratio or latency
    return _endpoints[_random.nextInt(_endpoints.length)];
  }

  _Endpoint _get(Endpoint endpoint) =>
      _endpoints.firstWhere((e) => e.endpoint == endpoint, orElse: () => null);

  void join(Endpoint endpoint) {
    _Endpoint e = _get(endpoint);
    if (e != null) {
      return;
    }
    _endpoints.add(new _Endpoint(name, endpoint));
  }

  void leave(Endpoint endpoint) {
    _Endpoint e = _get(endpoint);
    if (e == null) {
      return;
    }
    e._isClosed = true;
    _endpoints.remove(e);
  }
}

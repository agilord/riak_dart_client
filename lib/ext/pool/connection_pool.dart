// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library connection_pool;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'pool.dart';
export 'pool.dart';

class Endpoint {
  final String host;
  final int port;

  Endpoint(this.host, this.port);

  @override
  String toString() =>
      "$host:$port";

  @override
  bool operator ==(Endpoint other) =>
      host == other.host &&
      port == other.port;

  int get hashCode =>
      host.hashCode + port;
}

class Member<T> {
  final Endpoint endpoint;
  final List<T> _connections = [];

  bool _active = true;
  int _errorSeq = 0;
  Completer _closeCompleter;

  Member(this.endpoint);

  bool get isActive => _active;
  int get weight => isActive ? min(10 - _errorSeq, 1) : 0;

  void addConnection(T connection) =>
    _connections.add(connection);

  void removeConnection(T connection) {
    _connections.remove(connection);
    if (!isActive && _closeCompleter != null && _connections.isEmpty) {
      _closeCompleter.complete();
    }
  }

  void processEvent(PoolEvent event) {
    if (event.isError) {
      _errorSeq++;
    } else {
      _errorSeq = 0;
    }
  }

  Future close() {
    _active = false;
    if (_connections.isEmpty) {
      return new Future.value();
    } else {
      _closeCompleter = new Completer();
      return _closeCompleter.future;
    }
  }
}

abstract class ConnectionPool<T> extends Pool<T> {

  final Random _random = new Random();
  Expando _memberAttr = new Expando();
  List<Member> _members = [];

  Future<T> connect(Endpoint endpoint, Duration timeout);
  Future disconnect(Endpoint endpoint, T connection);

  Member join(Endpoint endpoint) {
    Member m =
        _members.firstWhere((m) => m.endpoint == endpoint, orElse: () => null);
    if (m == null) {
      m = createMember(endpoint);
      _members.add(m);
    }
    return m;
  }

  Future leave(Endpoint endpoint) {
    Member m =
        _members.firstWhere((m) => m.endpoint == endpoint, orElse: () => null);
    if (m != null) {
      _members.remove(m);
      return m.close();
    } else {
      return new Future.value();
    }
  }

  @override
  Future<T> create({Duration timeout}) {
    Member m = selectMember(_members);
    DateTime now = _now();
    return connect(m.endpoint, timeout).then((o) {
      _memberAttr[o] = m;
      if (m.isActive) {
        m.addConnection(o);
        return o;
      } else {
        destroy(o);
        throw "${m.endpoint} become inactive";
      }
    }, onError: (e, st) {
      m.processEvent(new PoolEvent(null, PoolEvent.FACTORY_ERROR,
          _now().difference(now), e, st));
      throw e;
    });
  }

  @override
  Future destroy(T object) {
    Member m = _memberAttr[object];
    Endpoint ep = m == null ? null : m.endpoint;
    return disconnect(ep, object).whenComplete(() {
      m.removeConnection(object);
    });
  }

  Member getMember(T object) =>
      _memberAttr[object];

  Member createMember(Endpoint endpoint) =>
      new Member(endpoint);

  Member selectMember(List<Member> members) {
    if (members.isEmpty) {
      return null;
    }
    int sumWeight = members.fold(0, (sum, m) => sum + m.weight);
    if (sumWeight <= 0) {
      return null;
    }
    int r = _random.nextInt(sumWeight);
    for (Member m in members) {
      r -= m.weight;
      if (r < 0) {
        return m;
      }
    }
    return null;
  }

  @override
  void processEvent(PoolEvent event) {
    super.processEvent(event);
    Member m = event.object == null ? null : getMember(event.object);
    if (m != null) {
      m.processEvent(event);
    }
  }

  DateTime _now() =>
      new DateTime.now();
}

class SocketPool extends ConnectionPool<Socket> {

  SocketPool();

  SocketPool.withEndpoint(String host, int port) {
    join(new Endpoint(host, port));
  }

  @override
  Future<Socket> connect(Endpoint endpoint, Duration timeout) =>
    Socket.connect(endpoint.host, endpoint.port);

  @override
  Future disconnect(Endpoint endpoint, Socket connection) =>
      connection.close();
}

class HttpClientPool extends ConnectionPool<HttpClient> {

  HttpClientPool();

  HttpClientPool.withEndpoint(String host, int port) {
    join(new Endpoint(host, port));
  }

  @override
  Future<HttpClient> connect(Endpoint endpoint, Duration timeout) {
    return new Future.value(
        new HttpClient()
            ..idleTimeout = idleTimeout);
  }

  @override
  Future disconnect(Endpoint endpoint, HttpClient client) {
    client.close(force: true);
    return new Future.value();
  }

  Future<HttpClientRequest> openUrl({
      String method: "get",
      String scheme: "http",
      String path,
      Map<String, String> queryParameters,
      Future releaseOn}) {
    assert(releaseOn != null);
    return acquire(releaseOn: releaseOn)
        .then((HttpClient httpClient) {
          Member m = getMember(httpClient);
          var uri = new Uri(
              scheme: scheme,
              host: m.endpoint.host,
              port:m.endpoint.port,
              path: path,
              queryParameters: queryParameters);
          return httpClient.openUrl(method, uri);
        });
  }
}

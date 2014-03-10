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
  List<T> _connections = [];

  Member(this.endpoint);

  // TODO: collect latency stats
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
      // TODO: wait for existing connections closing (incl. destroy method)
      return new Future.value();
    } else {
      return new Future.value();
    }
  }

  @override
  Future<T> create({Duration timeout}) {
    Member m = selectMember(_members);
    return connect(m.endpoint, timeout).then((o) {
      _memberAttr[o] = m;
      m._connections.add(o);
      return o;
    });
  }

  @override
  Future destroy(T object) {
    Member m = _memberAttr[object];
    Endpoint ep = m == null ? null : m.endpoint;
    return disconnect(ep, object).whenComplete(() {
      m._connections.remove(object);
    });
  }

  Member getMember(T object) =>
      _memberAttr[object];

  Member createMember(Endpoint endpoint) =>
      new Member(endpoint);

  Member selectMember(List<Member> members) {
    // TODO: select based on latency / errors / load
    return members[_random.nextInt(members.length)];
  }
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
}

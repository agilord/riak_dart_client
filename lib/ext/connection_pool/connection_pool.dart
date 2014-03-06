// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library connection_pool;

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import '../latency/latency.dart';

part 'cluster.dart';
part 'factory.dart';
part 'pool_impl.dart';

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

class Connection<T> {
  final Endpoint endpoint;
  final T connection;
  final Completer _return;
  Connection(this.endpoint, this.connection, this._return);

  void complete() {
    if (_return.isCompleted) {
      return;
    }
    _return.complete();
  }

  void completeError(Object error, [StackTrace stackTrace]) {
    if (_return.isCompleted) {
      return;
    }
    _return.completeError(error, stackTrace);
  }
}

abstract class ConnectionPool<T> {

  factory ConnectionPool.http(String name) =>
      new _Pool<HttpClient>(name, new _HttpClientFactory());

  factory ConnectionPool.socket(String name) =>
      new _Pool<Socket>(name, new _SocketFactory());

  Duration idleTimeout;
  Duration connectTimeout;
  int maxPoolSize;

  join(Endpoint endpoint);
  leave(Endpoint endpoint);

  Future<Connection<T>> open();
  Future close();
}


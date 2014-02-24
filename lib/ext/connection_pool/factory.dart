// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of connection_pool;

abstract class _Factory<T> {
  void open(Endpoint endpoint, Completer completer);
  void close(T connection);
}

class _HttpClientFactory implements _Factory<HttpClient> {

  void open(Endpoint endpoint, Completer completer) {
    completer.complete(new HttpClient());
  }

  void close(HttpClient connection) {
    connection.close(force: true);
  }
}

class _SocketFactory implements _Factory<Socket> {

  void open(Endpoint endpoint, Completer completer) {
    Socket.connect(endpoint.host, endpoint.port).then((conn) {
      if (completer.isCompleted) {
        conn.close();
        return;
      }
      completer.complete(conn);
    }, onError: (e, st) {
      if (completer.isCompleted) {
        return;
      }
      completer.completeError(e, st);
    });
  }

  void close(Socket connection) {
    connection.close();
  }
}

// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library latency;

import 'dart:math';

import '../../../lib/ext/connection_pool/connection_pool.dart';
import 'package:unittest/unittest.dart';
import 'dart:async';
import 'dart:io';

main() {
  Random random = new Random(1234);
  _EchoServer server;
  group('echo server', () {
    setUp(() {
      server = new _EchoServer();
      return server.connect();
    });
    tearDown(() => server.close());
    test('single thread socket pool', () {
      ConnectionPool pool = new ConnectionPool.socket("echo");
      pool.join(new Endpoint(server.host, server.port));
      Future f = pool.open().then((conn) {
        Socket socket = conn.connection;
        socket.add([0, 2, 11]);
        socket.flush();

        Completer c = new Completer();
        List<int> buffer = [];
        socket.listen((List<int> data) {
          buffer.addAll(data);
          if (buffer.length == 3) {
            if (buffer[0] == 0 && buffer[1] == 2 && buffer[2] == 11) {
              c.complete(conn);
            } else {
              c.completeError(buffer);
            }
          } else if (buffer.length > 3) {
            c.completeError(buffer);
          }
        }, onDone: () {
          if (!c.isCompleted) {
            c.completeError("not completed");
          }
        });
        return c.future;
      }).then((Connection conn) {
        conn.complete();
        return true;
      }).then((_) {
        expect(server.byteCount[0], 1);
        expect(server.byteCount[2], 1);
        expect(server.byteCount[11], 1);
        expect(server._errorCount, 0);
        return pool.close();
      });
      expect(f, completes);
    });
  });

  group('http (no connection)', () {
    test('pool handling', () {
      ConnectionPool pool = new ConnectionPool.http("echo");
      pool.join(new Endpoint("127.0.0.1", 8080));
      Future f1 = pool.open();
      Future f2 = pool.open();
      Future f = Future.wait([ f1, f2 ]);
      HttpClient hc1 = null;
      f.then((List conns) {
        Connection c1 = conns[0];
        Connection c2 = conns[1];
        hc1 = c1.connection;
        c1.complete();
        c2.complete();
        return pool.open();
      }).then((conn) {
        expect(hc1, conn.connection);
        conn.complete();
        return pool.close();
      });
      expect(f, completes);
    });
  });
}

class _EchoServer {
  String host = "127.0.0.1";
  ServerSocket _socket;
  int _errorCount = 0;
  Map<int, int> byteCount = new Map();
  int get port => _socket == null ? null : _socket.port;

  Future<int> connect({ int port: 10000, int maxPort: 20000 }) {
    Completer c = new Completer();
    _connect(port, maxPort, c);
    return c.future;
  }

  _connect(int port, int maxPort, Completer c) {
    ServerSocket.bind(host, port).then((s) {
      c.complete(port);
      print("Server bind on $port");
      _setup(s);
    }, onError: (e, st) {
      if (port < maxPort) {
        _connect(port+1, maxPort, c);
      } else {
        c.completeError("Couldn't bind port // $e", st);
      }
    });
  }

  _setup(ServerSocket ss) {
    _socket = ss;
    _socket.listen((Socket s) {
      s.listen((List<int> data) {
        for (int d in data) {
          int bc = byteCount[d];
          bc = bc == null ? 1 : bc + 1;
          byteCount[d] = bc;
        }
        s.add(data);
        s.flush();
      }, onError: (e, st) {
        _errorCount++;
      }, onDone: () {
        s.close();
      }, cancelOnError: true);
    }, onError: (e, st) {
      _errorCount++;
      print(e);
      print(st);
    });
  }

  Future close() =>
    _socket.close();
}

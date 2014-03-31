// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library socket_pool_test;

import 'dart:async';
import 'dart:io';
import 'dart:math';

import '../../../lib/ext/pool/connection_pool.dart';
import 'package:unittest/unittest.dart';

main() {
  group('echo server', () {
    _EchoServer server;
    setUp(() {
      server = new _EchoServer();
      return server.connect();
    });
    tearDown(() => server.close());
    test('single thread socket pool', () {
      ConnectionPool<Socket> pool = new SocketPool();
      pool.join(new Endpoint(server.host, server.port));

      Future f = pool.acquire().then((Socket socket) {
        socket.add([0, 2, 11]);
        socket.flush();

        Completer c = new Completer();
        List<int> buffer = [];
        socket.listen((List<int> data) {
          buffer.addAll(data);
          if (buffer.length == 3) {
            if (buffer[0] == 0 && buffer[1] == 2 && buffer[2] == 11) {
              c.complete(socket);
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
      }).then((Socket socket) {
        pool.release(socket);
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

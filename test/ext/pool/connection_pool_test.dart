// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library connection_pool_test;

import '../../../lib/ext/pool/connection_pool.dart';
import 'package:unittest/unittest.dart';
import 'dart:async';

main() {
  Future work(String worker, Pool<Obj> pool, int millis, List log) =>
    pool.acquire().then((v) {
      log.add("$worker+$v");
      return new Future.delayed(new Duration(milliseconds: millis), () => v);
    }).then((v) {
      log.add("$worker-$v");
      pool.release(v);
    });

  group('Cluster with 1-client', () {
    Pool pool;
    setUp(() => pool = _createCluster());
    tearDown(() => pool.close());
    test('serial', () {
      List log = [];
      Future f = work('a', pool, 100, log)
          .then((_) {
            return work('a', pool, 200, log);
          }).then((_) {
            return work('a', pool, 100, log);
          }).then((_) {
            expect(log, ['a+0/X:11', 'a-0/X:11',
                         'a+0/X:11', 'a-0/X:11',
                         'a+0/X:11', 'a-0/X:11']);
          });
      expect(f, completes);
    });
  });
}

ObjPool _createCluster() =>
    new ObjPool()
        ..maxPooled = 2
        ..join(new Endpoint("X", 11))
        ..join(new Endpoint("Y", 12))
        ..join(new Endpoint("Z", 13));

class ObjPool extends ConnectionPool<Obj> {

  int _counter = 0;
  int _member = 0;

  @override
  Future<Obj> connect(Endpoint endpoint, Duration timeout) {
    return new Future.value(new Obj("${_counter++}/$endpoint"));
  }

  @override
  Future disconnect(Endpoint endpoint, Obj connection) {
    return new Future.value();
  }

  @override
  Member selectMember(List<Member> members) {
    return members[(_member++) % members.length];
  }
}

class Obj {
  final String value;
  Obj(this.value);
  toString() => value;
}


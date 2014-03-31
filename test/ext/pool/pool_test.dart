// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library pool_test;

import '../../../lib/ext/pool/pool.dart';
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

  group('Pool with 1-client', () {
    Pool<Obj> pool;
    setUp(() => pool = _createPool());
    tearDown(() => pool.close());
    test('serial', () {
      List log = [];
      Future f = work('a', pool, 100, log)
          .then((_) {
            return work('a', pool, 200, log);
          }).then((_) {
            return work('a', pool, 100, log);
          }).then((_) {
            expect(log, ['a+0', 'a-0', 'a+0', 'a-0', 'a+0', 'a-0']);
          });
      expect(f, completes);
    });
  });

  group('Pool with 2-clients', () {
    Pool<Obj> pool;
    setUp(() => pool = _createPool());
    tearDown(() => pool.close());
    test('10/10/10 10/10/10', () {
      List log = [];
      Future f1 = work('a', pool, 10, log)
          .then((_) {
            return work('a', pool, 10, log);
          }).then((_) {
            return work('a', pool, 10, log);
          });
      Future f2 = work('b', pool, 10, log)
          .then((_) {
            return work('b', pool, 10, log);
          }).then((_) {
            return work('b', pool, 10, log);
          });
      Future f = Future.wait([f1, f2]).then((_) {
        // TODO: check if other means can be used (e.g. not sort)
        expect(log..sort(),
              ['a+0', 'b+1', 'a-0', 'b-1', 'a+0', 'b+1',
               'a-0', 'b-1', 'a+0', 'b+1', 'a-0', 'b-1']..sort());
      });
      expect(f, completes);
    });

    test('10/10/10 5/50/50', () {
      List log = [];
      Future f1 = work('a', pool, 10, log)
          .then((_) {
            return work('a', pool, 10, log);
          }).then((_) {
            return work('a', pool, 10, log);
          });
      Future f2 = work('b', pool, 5, log)
          .then((_) {
            return work('b', pool, 50, log);
          }).then((_) {
            return work('b', pool, 50, log);
          });
      Future f = Future.wait([f1, f2]).then((_) {
        // TODO: check if other means can be used (e.g. not sort)
        expect(log..sort(),
              ['a+0', 'b+1', 'b-1', 'b+1', 'a-0', 'a+0',
               'a-0', 'a+0', 'a-0', 'b-1', 'b+0', 'b-0']..sort());
      });
      expect(f, completes);
    });
  });

  group('Pool with 3-clients', () {
    Pool<Obj> pool;
    setUp(() => pool = _createPool());
    tearDown(() => pool.close());
    test('10/10/10 10/10/10 10/10/10', () {
      List log = [];
      Future f1 = work('a', pool, 10, log)
          .then((_) {
            return work('a', pool, 10, log);
          }).then((_) {
            return work('a', pool, 10, log);
          });
      Future f2 = work('b', pool, 10, log)
          .then((_) {
            return work('b', pool, 10, log);
          }).then((_) {
            return work('b', pool, 10, log);
          });
      Future f3 = work('c', pool, 10, log)
          .then((_) {
            return work('c', pool, 10, log);
          }).then((_) {
            return work('c', pool, 10, log);
          });
      Future f = Future.wait([f1, f2, f3]).then((_) {
        // TODO: check if other means can be used (e.g. not sort)
        expect(log..sort(),
              ['a+0', 'b+1', 'a-0', 'b-1', 'c+0', 'a+1', 'c-0', 'a-1',
               'b+0', 'c+1', 'b-0', 'c-1', 'a+0', 'b+1', 'a-0', 'b-1',
               'c+0', 'c-0']..sort());
      });
      expect(f, completes);
    });

    test('10/10/10 5/50/50 10/10/20', () {
      List log = [];
      Future f1 = work('a', pool, 10, log)
          .then((_) {
            return work('a', pool, 10, log);
          }).then((_) {
            return work('a', pool, 10, log);
          });
      Future f2 = work('b', pool, 5, log)
          .then((_) {
            return work('b', pool, 50, log);
          }).then((_) {
            return work('b', pool, 50, log);
          });
      Future f3 = work('c', pool, 10, log)
          .then((_) {
            return work('c', pool, 10, log);
          }).then((_) {
            return work('c', pool, 20, log);
          });
      Future f = Future.wait([f1, f2, f3]).then((_) {
        // TODO: check if other means can be used (e.g. not sort)
        expect(log..sort(),
              ['a+0', 'b+1', 'b-1', 'c+1', 'a-0', 'b+0', 'c-1', 'a+1',
               'a-1', 'c+1', 'c-1', 'a+1', 'a-1', 'c+1', 'b-0', 'b+0',
               'c-1', 'b-0']..sort());
      });
      expect(f, completes);
    });
  });
}

Pool<Obj> _createPool() => new ObjFactory()..maxPooled = 2;

class ObjFactory extends Pool<Obj> {

  int _counter = 0;

  @override
  Future<Obj> create({Duration timeout}) {
    return new Future.value(new Obj(_counter++));
  }

  @override
  Future destroy(Obj object) {
    return new Future.value();
  }
}

class Obj {
  final int value;
  Obj(this.value);
  toString() => '$value';
}


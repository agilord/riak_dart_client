// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library reservoir_test;

import 'dart:math';

import '../../../lib/ext/metrics/metrics.dart';
import 'package:unittest/unittest.dart';

main() {
  Random random = new Random(1234);
  group('normal counter', () {
    test('fixed', () {
      Counter counter = new Counter();
      for (int i = 0; i < 10500; i++) {
        counter.trackValue(i % 1000);
      }
      expect(counter.count, 10500);
      expect(counter.min, 0);
      expect(counter.max, 999);
      expect(counter.avg, closeTo(487.5, 0.5));
    });
    test('random', () {
      Counter counter = new Counter();
      for (int i = 0; i < 10500; i++) {
        counter.trackValue(random.nextInt(1000));
      }
      expect(counter.count, 10500);
      expect(counter.min, 0);
      expect(counter.max, 999);
      expect(counter.avg, closeTo(500, 20));
    });
  });
  group('decaying counter', () {
    NowTicker ticker = new NowTicker();
    setUp(() => ticker.init());
    tearDown(() => ticker.destroy());
    test('fixed', () {
      Counter counter = new Counter(window: new Duration(minutes: 1));
      for (int i = 0; i < 10500; i++) {
        counter.trackValue(i % 1000);
        ticker.tick(200);
      }
      expect(counter.count, 299);
      expect(counter.min, 208);
      expect(counter.max, 499);
      expect(counter.avg, closeTo(350, 20));
    });
    test('random', () {
      Counter counter = new Counter(window: new Duration(minutes: 1));
      for (int i = 0; i < 10500; i++) {
        counter.trackValue(random.nextInt(1000));
        ticker.tick(100);
      }
      expect(counter.count, 599);
      expect(counter.min, 5);
      expect(counter.max, 998);
      expect(counter.avg, closeTo(500, 20));
    });
  });
}

class NowTicker {

  var _oldFn;
  DateTime now = new DateTime.now();

  init() {
    _oldFn = metrics_now;
    metrics_now = () => now;
  }

  destroy() {
    metrics_now = _oldFn;
  }

  tick(int ms) {
    now = now.add(new Duration(milliseconds: ms));
  }
}

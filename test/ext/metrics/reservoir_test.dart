// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library reservoir_test;

import 'dart:math';

import '../../../lib/ext/metrics/metrics.dart';
import 'package:unittest/unittest.dart';

main() {
  Random random = new Random(1234);
  group('normal reservoir', () {
    test('fixed', () {
      Reservoir reservoir = new Reservoir(random: random);
      for (int i = 0; i < 10500; i++) {
        reservoir.trackValue(i % 1000);
      }
      expect(reservoir.count, 10500);
      expect(reservoir.min, 0);
      expect(reservoir.max, 999);
      expect(reservoir.avg, closeTo(487.5, 0.5));
      expect(reservoir.q50, closeTo(500, 20));
      expect(reservoir.q75, closeTo(750, 30));
      expect(reservoir.q90, closeTo(900, 20));
      expect(reservoir.q99, closeTo(990, 20));
    });
    test('random', () {
      Reservoir reservoir = new Reservoir(random: random);
      for (int i = 0; i < 10500; i++) {
        reservoir.trackValue(random.nextInt(1000));
      }
      expect(reservoir.count, 10500);
      expect(reservoir.min, 0);
      expect(reservoir.max, 999);
      expect(reservoir.avg, closeTo(500, 10));
      expect(reservoir.q50, closeTo(500, 20));
      expect(reservoir.q75, closeTo(750, 30));
      expect(reservoir.q90, closeTo(900, 20));
      expect(reservoir.q99, closeTo(990, 20));
    });
  });
  group('decaying reservoir', () {
    NowTicker ticker = new NowTicker();
    setUp(() => ticker.init());
    tearDown(() => ticker.destroy());
    test('fixed', () {
      Reservoir reservoir = new Reservoir(
          random: random,
          window: new Duration(minutes: 1));

      for (int i = 0; i < 10500; i++) {
        reservoir.trackValue(i % 1000);
        ticker.tick(100);
      }
      expect(reservoir.count, 599);
      expect(reservoir.min, 0);
      expect(reservoir.max, 999);
      expect(reservoir.avg, closeTo(365, 10));
      expect(reservoir.q50, closeTo(400, 20));
      expect(reservoir.q75, closeTo(700, 30));
      expect(reservoir.q90, closeTo(900, 20));
      expect(reservoir.q99, closeTo(990, 20));
    });
    test('random', () {
      Reservoir reservoir = new Reservoir(
          random: random,
          window: new Duration(minutes: 1));
      for (int i = 0; i < 10500; i++) {
        reservoir.trackValue(random.nextInt(1000));
        ticker.tick(100);
      }
      expect(reservoir.count, 599);
      expect(reservoir.min, 2);
      expect(reservoir.max, 999);
      expect(reservoir.avg, closeTo(500, 10));
      expect(reservoir.q50, closeTo(500, 20));
      expect(reservoir.q75, closeTo(750, 30));
      expect(reservoir.q90, closeTo(900, 20));
      expect(reservoir.q99, closeTo(990, 20));
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

// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library latency;

import 'dart:math';

import '../../../lib/ext/latency/latency.dart';
import 'package:unittest/unittest.dart';

main() {
  Random random = new Random(1234);
  group('simple latency', () {
    test('fixed', () {
      Tracker tracker = new Tracker("test", random: random);
      for (int i = 0; i < 10500; i++) {
        tracker.add(new Duration(microseconds: i % 1000));
      }
      Latency latency = tracker.minute;
      expect(latency.event, "test");
      expect(latency.period, Period.MINUTE);
      expect(latency.count, 10500);
      expect(latency.min.inMicroseconds, 0);
      expect(latency.max.inMicroseconds, 999);
      expect(latency.avg.inMicroseconds, 487);
      expect(latency.load, closeTo(0.085, 0.001));
      expect(latency.quantiles.p50.inMicroseconds, closeTo(300, 20));
      expect(latency.quantiles.p90.inMicroseconds, closeTo(800, 20));
      expect(latency.quantiles.p99.inMicroseconds, closeTo(990, 20));
      expect(latency.quantiles.p999.inMicroseconds, closeTo(995, 4));
    });
    test('random', () {
      Tracker tracker = new Tracker("test", random: random);
      for (int i = 0; i < 10500; i++) {
        tracker.add(new Duration(microseconds: random.nextInt(1000)));
      }
      Latency latency = tracker.minute;
      expect(latency.event, "test");
      expect(latency.period, Period.MINUTE);
      expect(latency.count, 10500);
      expect(latency.min.inMicroseconds, 0);
      expect(latency.max.inMicroseconds, 999);
      expect(latency.avg.inMicroseconds, closeTo(500, 20));
      expect(latency.load, closeTo(0.088, 0.002));
      expect(latency.quantiles.p50.inMicroseconds, closeTo(500, 25));
      expect(latency.quantiles.p90.inMicroseconds, closeTo(900, 20));
      expect(latency.quantiles.p99.inMicroseconds, closeTo(990, 20));
      expect(latency.quantiles.p999.inMicroseconds, closeTo(995, 4));
    });
  });

}
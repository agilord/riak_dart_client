// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library latency;

import 'dart:async';
import 'dart:collection';
import 'dart:math';

part 'sink.dart';
part 'time_source.dart';
part 'tracker_impl.dart';

/** Simple identifier for the [Latency.period] field. */
class Period {
  static final String MINUTE = "minute";
  static final String HOUR   = "hour";
  static final String DAY    = "day";
}

/** Holds the observed latency values for a given event for a given time. */
class Latency {
  final String event;
  final String period;
  final DateTime timestamp;

  final int count;      // number of events in the given period
  final double load;    // service load, total event sum / time period

  final Duration min;   // minimum time
  final Duration avg;   // average time
  final Duration max;   // maximum time

  final Quantiles quantiles;

  Latency(this.event, this.period, this.timestamp,
          this.count, this.load, this.min, this.avg, this.max, this.quantiles);
}

/**
 * Provides quantiles of the sampled latency values.
 * The sampling is through reservoir sampling, */
class Quantiles {
  final List<Duration> percentiles;
  final Duration p999; // 99.9% percentile

  Quantiles(this.percentiles, this.p999);

  Duration get p25 => percentiles[25];
  Duration get p50 => percentiles[50];
  Duration get p75 => percentiles[75];
  Duration get p90 => percentiles[90];
  Duration get p95 => percentiles[95];
  Duration get p99 => percentiles[99];
}

/**
 * Tracks the [Duration] of the events over the last minute, hour and day.
 */
abstract class Tracker implements StreamSink<Duration> {

  factory Tracker(String event, {bool quantiles: true, Random random}) =>
      new _Tracker(event, quantiles, random: random);

  Latency get minute;
  Latency get hour;
  Latency get day;

  Iterable<Latency> get stats;
}

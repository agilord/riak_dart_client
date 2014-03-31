// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library metrics;

import 'dart:collection';
import 'dart:math' as math;

part 'counter.dart';
part 'reservoir.dart';
part 'tracker.dart';

abstract class Metric {
  void writeValues(String name, Map<String, num> map);
}

// TODO: consider using quiver's Clock
// http://google.github.io/quiver-dart/#quiver/quiver-time.Clock@id_now

typedef DateTime NowFn();
NowFn metrics_now =
    () => new DateTime.now();

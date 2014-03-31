// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of metrics;

abstract class Tracker {

  factory Tracker() => new _Tracker();

  track(String name, Metric metric);
  remove(metric);

  Map<String, num> getValues();
}

class _Tracker implements Tracker {

  Map<String, Metric> _map = new LinkedHashMap();

  @override
  Map<String, num> getValues() {
    Map<String, num> map = new LinkedHashMap();
    _map.forEach((k, v) {
      v.writeValues(k, map);
    });
    return map;
  }

  @override
  track(String name, Metric metric) {
    assert(!_map.containsKey(name));
    _map[name] = metric;
  }

  @override
  remove(metric) {
    if (metric is String) {
      _map.remove(metric);
    } else if (metric is Metric) {
      String key;
      for (String k in _map.keys) {
        if (_map[k] == metric) {
          key = k;
          break;
        }
      }
      _map.remove(key);
    }
  }
}



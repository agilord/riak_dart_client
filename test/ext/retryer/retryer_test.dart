// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library retryer;

import 'dart:async';

import '../../../lib/ext/retryer/retryer.dart';
import 'package:unittest/unittest.dart';

main() {

  group('basic retryer', () {
    test('success at first', () {
      Retryer retryer = new Retryer((Completer c) {
        new Timer(new Duration(milliseconds: 10), () {
          c.complete(123);
        });
      });
      Future<int> f = retryer.future.then((int v) {
        expect(v, 123);
        expect(retryer.wasSuccess, true);
      });
      expect(f, completes);
    });
    test('success at third', () {
      int cnt = 0;
      Retryer retryer = new Retryer((Completer c) {
        new Timer(new Duration(milliseconds: 10), () {
          if (cnt == 2) {
            c.complete(123);
          } else {
            cnt++;
            c.completeError("bad");
          }
        });
      });
      Future<int> f = retryer.future.then((int v) {
        expect(v, 123);
        expect(retryer.wasSuccess, true);
      });
      expect(f, completes);
    });
    test('fail', () {
      int cnt = 0;
      Retryer retryer = new Retryer((Completer c) {
        new Timer(new Duration(milliseconds: 10), () {
          c.completeError("bad");
        });
      });
      Future f = retryer.future.catchError((e, st) {
        expect(retryer.wasSuccess, false);
        throw e;
      });
      expect(f, throwsA("max tries have reached: 3, with error: bad"));
    });
  });

}

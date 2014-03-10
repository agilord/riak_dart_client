// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of riak_test;

class LocalHttpTest {
  TestConfig config;
  riak.Client client;
  riak.Bucket bucket;

  LocalHttpTest(this.config) {
    this.client = new riak.Client.http(config.httpHost, config.httpPort);
    this.bucket = client.getBucket(config.bucket);
  }

  Future<riak.Response> deleteKey(String key) {
    if (config.keepData) {
      return new Future.value(new riak.Response(200, true));
    } else {
      return bucket.delete(key);
    }
  }

  File localFile(String relativePath) {
    return new File('${config.directory.path}/$relativePath');
  }

  run() {
    _cleanUp().then((_) => _run());
  }

  Future _cleanUp() {
    return Future.wait([
        bucket.setProps(null),
        bucket.delete("k1"),
        bucket.delete("k2"),
        bucket.delete("k3"),
        bucket.delete("k4"),
        bucket.delete("k6")
      ]);
  }

  _run() {
    group('Riak HTTP: ', () {
      test('simple run', () {
        var vtag1 = null;
        DateTime lastModified1 = null;

        Future f = client.listBuckets().toList()
            .then((buckets) {
              if (!config.skipDataCheck) {
                expect(buckets, hasLength(0));
              }
              return bucket.fetch("k1");
            })
            .then((response) {
              if (!config.skipDataCheck) {
                expect(response.success, false);
              }
              return bucket.store("k1", new riak.Content.json({"x":1}));
            })
            .then((response) {
              expect(response.success, true);
              return bucket.fetch("k1");
            })
            .then((response) {
              expect(response.success, true);
              riak.Object obj = response.result;
              vtag1 = obj.vtag;
              lastModified1 = obj.lastModified;
              expect(obj.content.asJson["x"], 1);
              expect(obj.vtag, isNotNull);
              expect(obj.lastModified, isNotNull);
              DateTime now = new DateTime.now();
              expect(now.difference(obj.lastModified).inSeconds, lessThan(15));
              return obj.store(new riak.Content.json({"x":2}));
            })
            .then((response) {
              expect(response.success, true);
              return bucket.listKeys().toList();
            })
            .then((keys) {
              if (!config.skipDataCheck) {
                expect(keys, hasLength(1));
                expect(keys[0], "k1");
              }
              expect(keys, contains("k1"));
              return bucket.fetch("k1");
            })
            .then((response) {
              expect(response.success, true);
              riak.Object obj = response.result;
              expect(obj.content.asJson["x"], 2);
              return obj.store(new riak.Content.json({"x":3}), returnBody: true);
            })
            .then((response) {
              expect(response.success, true);
              riak.Object obj = response.result;
              expect(obj.vtag, isNotNull);
              expect(obj.vtag, isNot(vtag1));
              expect(obj.lastModified, isNotNull);
              expect(
                  lastModified1.difference(obj.lastModified).inSeconds,
                  lessThan(15));
              expect(obj.content.asJson["x"], 3);
              return obj.delete(); // testing delete, will not keep data
            })
            .then((response) {
              expect(response.success, true);
              return bucket.fetch("k1");
            })
            .then((response) {
              expect(response.success, false);
              return client.ping();
            })
            .then((response) {
              expect(response.success, true);
            });
        expect(f, completes);
      });

      test('test index store and query', () {
        Future f = bucket.fetch("k2")
            .then((response) {
              if (!config.skipDataCheck) {
                expect(response.success, false);
              }
              var index = new riak.IndexBuilder()
              ..addInt("index1", 2)
              ..addString("index2", "c");
            return bucket.store("k2",
                new riak.Content.json({"x":1}, index:index.build()));
          })
          .then((response) {
            expect(response.success, true);
            return bucket.getIntIndex("index1").queryRange(1, 2).toList();
          })
          .then((result) {
            expect(result, hasLength(1));
            expect(result[0], "k2");
            return bucket.getIntIndex("index1").queryRange(0, 1).toList();
          })
          .then((result) {
            expect(result, hasLength(0));
            return bucket.getStringIndex("index2").queryEquals("c").toList();
          })
          .then((result) {
            expect(result, hasLength(1));
            expect(result[0], "k2");
            return deleteKey("k2");
          })
          .then((response) {
            expect(response.success, true);
          });
        expect(f, completes);
      });

      test('binary file', () {
        Future f = bucket.fetch("k3")
            .then((response) {
              if (!config.skipDataCheck) {
                expect(response.success, false);
              }
              return bucket.store("k3",
                  new riak.Content.stream(
                      localFile("../lib/riak_client.dart").openRead(),
                      type:new ContentType("test", "binary")));
            })
            .then((response) {
              expect(response.success, true);
              return bucket.fetch("k3");
            })
            .then((response) {
              expect(response.success, true);
              riak.Object obj = response.result;
              expect(riak.MediaType.typeEquals(
                  obj.content.type, new ContentType("test", "binary")), true);
              return obj.content.asStream.toList();
            })
            .then((content) {
              new riak.BucketProps(replicas: 2);
              expect(content, hasLength(
                  localFile("../lib/riak_client.dart").lengthSync()));
              expect(content,
                  localFile("../lib/riak_client.dart").readAsBytesSync());
              return deleteKey("k3");
            })
            .then((response) {
              expect(response.success, true);
            });
        expect(f, completes);
      });

      test('bucket props', () {
        Future f = bucket.fetch("k4")
            .then((response) {
              if (!config.skipDataCheck) {
                expect(response.success, false);
              }
              return bucket.store("k4", new riak.Content.text("abc123"));
            })
            .then((response) {
              expect(response.success, true);
              return bucket.getProps();
            })
            .then((props) {
              // expect(props.allowSiblings, false);
              return bucket.setProps(new riak.BucketProps(allowSiblings: true));
            })
            .then((response) {
              expect(response.success, true);
              return bucket.getProps();
            })
            .then((props) {
              expect(props.allowSiblings, true);
              return bucket.setProps(null); // reset
            })
            .then((response) {
              expect(response.success, true);
              return bucket.getProps();
            })
            .then((props) {
              // expect(props.allowSiblings, false);
              return deleteKey("k4");
            })
            .then((response) {
              expect(response.success, true);
            });
        expect(f, completes);
      });

      // We store a simplified Set<int> in the content body as text. The initial
      // value is just a single item (5), and in three parallel writes we add an
      // extra (2), (3, 7) and (8) separately. As we are using the same vclock
      // reference, these will cause Riak to create siblings.
      // On reading the value back, we will use a fetch-specific Resolver to
      // merge the values and check for (2, 3, 5, 7, 8). Production clients
      // should set the resolvers on the client or bucket level.
      test('conflicts', () {
        var vclock1;
        Future f = bucket.fetch("k5")
            .then((response) {
              if (!config.skipDataCheck) {
                expect(response.success, false);
              }
              if (response.success) {
                riak.Object obj = response.result;
                vclock1 = obj.vclock;
              }
              return bucket.setProps(new riak.BucketProps(
                  allowSiblings: true, lastWriteWins: false));
            })
            .then((response) {
              expect(response.success, true);
              return bucket.store("k5",
                  new riak.Content.text("5"), returnBody: true, vclock: vclock1);
            })
            .then((response) {
              expect(response.success, true);
              riak.Object obj = response.result;
              vclock1 = obj.vclock;
              expect(vclock1, isNotNull);
              return Future.wait([
                  // We need to set "ignoreChanges: true" in order to force
                  // sibling creation.
                  obj.store(
                      new riak.Content.text("2 5"), ignoreChanges: true),
                  obj.store(
                      new riak.Content.text("3 5 7"), ignoreChanges: true),
                  obj.store(
                      new riak.Content.text("5 8"), ignoreChanges: true),
                  ]);
            })
            .then((List<riak.Response> responses) {
              expect(responses.length, 3);
              expect(responses[0].success, true);
              expect(responses[1].success, true);
              expect(responses[2].success, true);
              return bucket.fetch("k5",
                  resolver: new riak.Resolver.merge((header, a, b) {
                    Set set = new Set();
                    set.addAll(a.asText.split(" "));
                    set.addAll(b.asText.split(" "));
                    List list = new List.from(set.map((s) => int.parse(s)));
                    return new riak.Content.text((list..sort()).join(" "));
                  }));
            })
            .then((response) {
              expect(response.success, true);
              riak.Object obj = response.result;
              expect(obj.vclock, isNotNull);
              expect(obj.vclock != vclock1, true);
              expect(obj.content.asText, "2 3 5 7 8");
              return deleteKey("k5");
            })
            .then((response) {
              expect(response.success, true);
              return bucket.setProps(null);
            })
            .then((response) {
              expect(response.success, true);
            });
        expect(f, completes);
      });

      test('conditional store and fetch', () {
        riak.Object obj1;
        var fullQuorum = new riak.Quorum.store(w: riak.Quorum.ALL,
            dw: riak.Quorum.ALL, pw: riak.Quorum.ALL);
        Future f = bucket.fetch("k6")
            .then((response) {
              if (!config.skipDataCheck) {
                expect(response.success, false);
              }
              return bucket.store("k6", new riak.Content.text("start"),
                  ifNew: true, returnBody: true, quorum: fullQuorum);
            })
            .then((response) {
              expect(response.success, true);
              riak.Object obj = response.result;
              expect(obj.content.asText, "start");
              expect(obj.vclock, isNotNull);
              expect(obj.vtag, isNotNull);
              expect(obj.lastModified, isNotNull);
              obj1 = obj;
              return obj.reload();
            })
            .then((response) {
              expect(response.success, true);
              expect(response.code, HttpStatus.NOT_MODIFIED);
              riak.Object obj = response.result;
              expect(obj.content, isNull);
              return bucket.store("k6", new riak.Content.text("second start"),
                  ifNew: true);
            })
            .then((response) {
              expect(response.success, false);
              expect(response.code, HttpStatus.PRECONDITION_FAILED);
              return bucket.fetch("k6");
            })
            .then((response) {
              expect(response.success, true);
              riak.Object obj = response.result;
              expect(obj.content.asText, "start");
              expect(obj.vclock, obj1.vclock);
              expect(obj.vtag, obj1.vtag);
              expect(obj.lastModified, obj1.lastModified);
              return obj1.store(new riak.Content.text("modified"),
                  quorum: fullQuorum);
            })
            .then((response) {
              expect(response.success, true);
              return bucket.fetch("k6");
            })
            .then((response) {
              expect(response.success, true);
              riak.Object obj2 = response.result;
              expect(obj2.content.asText, "modified");
              expect(obj2.vclock, isNot(obj1.vclock));
              expect(obj2.vtag, isNot(obj1.vtag));
              return obj1.reload();
            })
            .then((response) {
              expect(response.success, true);
              expect(response.code, HttpStatus.OK);
              riak.Object obj2 = response.result;
              expect(obj2.content.asText, "modified");
              expect(obj2.vclock, isNot(obj1.vclock));
              expect(obj2.vtag, isNot(obj1.vtag));
              return deleteKey("k6");
            })
            .then((response) {
              expect(response.success, true);
            });
        expect(f, completes);
      });

      test('counters', () {
        riak.Counter counter = bucket.getCounter("k7");
        int offset = 0;
        Future f = counter.fetch()
            .then((response) {
              if (!config.skipDataCheck) {
                expect(response.result, isNull);
              }
              if (response.result != null) {
                offset = response.result;
              }
              return bucket.setProps(new riak.BucketProps(allowSiblings: true));
            })
            .then((response) {
              expect(response.success, true);
              return counter.increment(amount: 10);
            })
            .then((response) {
              expect(response.success, true);
              return Future.wait([
                  counter.increment(),
                  counter.decrement(amount: 9),
                  counter.decrement(amount: 2) ]);
            })
            .then((List<riak.Response> responses) {
              expect(responses.length, 3);
              expect(responses[0].success, true);
              expect(responses[1].success, true);
              expect(responses[2].success, true);
              return counter.fetch();
            })
            .then((response) {
              expect(response.result, offset);
              return deleteKey("k7");
            })
            .then((response) {
              expect(response.success, true);
              return bucket.setProps(null);
            })
            .then((response) {
              expect(response.success, true);
            });
        expect(f, completes);
      });
    });

    group('close', () {
      test('close', () {
        expect(client.close(), completes);
      });
    });
  }
}

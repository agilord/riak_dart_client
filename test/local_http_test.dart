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
    return new File.fromPath(config.scriptPath.append(relativePath));
  }

  run() {
    group('Riak HTTP: ', () {

      test('simple run', () {
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
              expect(obj.content.asJson["x"], 1);
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
              expect(props.allow_mult, false);
              return bucket.setProps(new riak.BucketProps(allow_mult:true));
            })
            .then((response) {
              expect(response.success, true);
              return bucket.getProps();
            })
            .then((props) {
              expect(props.allow_mult, true);
              return bucket.setProps(null); // reset
            })
            .then((response) {
              expect(response.success, true);
              return bucket.getProps();
            })
            .then((props) {
              expect(props.allow_mult, false);
              return deleteKey("k4");
            })
            .then((response) {
              expect(response.success, true);
            });
        expect(f, completes);
      });
    });
  }
}

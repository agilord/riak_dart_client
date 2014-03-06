// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of riak_client;

class _ProtobufClient extends Client {

  final String host;
  final int port;

  _ProtobufClient(this.host, this.port,
      { Resolver resolverProvider(String bucket) }) : super._(resolverProvider);

  Future close() => null;

  Future<Response> delete(DeleteRequest req) {
    // TODO: implement delete
  }

  Future<Response<Object>> fetch(FetchRequest req) {
    // TODO: implement fetch
  }

  Future<Response<int>> fetchCounter(FetchCounterRequest req) {
    // TODO: implement fetchCounter
  }

  Future<BucketProps> getBucketProps(String bucket) {
    // TODO: implement getBucketProps
  }

  Future<Response> incrementCounter(IncrementCounterRequest req) {
    // TODO: implement incrementCounter
  }

  Stream<String> listBuckets() {
    var sc = new StreamController<String>();
    Uint8List req = new RpbListBucketsReq().writeToBuffer();
    Socket.connect(host, port)
      .then((socket) {
        socket.add(req);
        BytesBuilder builder = new BytesBuilder();
        socket.listen((List<int> data) {
          builder.add(data);
        }, onError:(e, st) {
          sc.addError(e, st);
          sc.close();
          socket.close();
        }, onDone: () {
          var resp = new RpbListBucketsResp.fromBuffer(builder.toBytes());
          resp.buckets
            .map((List<int> bucket) => new String.fromCharCodes(bucket))
            .forEach((String bucket) {
              sc.add(bucket);
            });
          sc.close();
          socket.close();
        });
      })
      .catchError((e) {
        sc.addError(e);
        sc.close();
      });
    return sc.stream;
  }

  Stream<String> listKeys(String bucket) {
    // TODO: implement listKeys
  }

  Future<Response> ping() {
    // TODO: implement ping
  }

  Stream<String> queryIndex(IndexRequest req) {
    // TODO: implement queryIndex
  }

  Future<Response> setBucketProps(String bucket, BucketProps props) {
    // TODO: implement setBucketProps
  }

  Future<Response<Object>> store(StoreRequest req) {
    // TODO: implement store
  }

}


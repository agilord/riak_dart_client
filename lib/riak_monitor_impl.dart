// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of riak_client;

/** A callback class that will be called on each significant event. */
abstract class OpMonitor {
  void onSuccess(int code);
  void onFailure(int code);
  void onError(error);
  void onDone();
}

/**
 * Proxies individual requests, tracks query performance, error rate for
 * individual Riak client.
 */
class _MonitoringClientProxy extends Client {

  final Client _client;
  final monitorProvider;

  _MonitoringClientProxy(this._client,
      OpMonitor this.monitorProvider(List<String> path, bool isStream))
        : super._(null);

  Future _proxyFuture(List<String> path, Future op()) {
    OpMonitor monitor = monitorProvider(path, false);
    var c = new Completer();
    op().then((v) {
      if (v is Response) {
        if (v.success) {
          monitor.onSuccess(v.code);
        } else {
          monitor.onFailure(v.code);
        }
      } else if (v != null) {
        monitor.onSuccess(HttpStatus.OK);
      } else {
        monitor.onFailure(HttpStatus.NOT_FOUND);
      }
      c.complete(v);
      monitor.onDone();
    }).catchError((e) {
      monitor.onError(e);
      c.completeError(e);
      monitor.onDone();
    });
    return c.future;
  }

  Stream _proxyStream(List<String> path, Stream<String> op()) {
    OpMonitor monitor = monitorProvider(path, true);
    Stream stream = op().asBroadcastStream();
    stream.listen((v) {
      monitor.onSuccess(HttpStatus.OK);
    }, onError: (e) {
      monitor.onError(e);
    }, onDone: () {
      monitor.onDone();
    }, cancelOnError: false);
    return stream;
  }

  Future<Response> ping() =>
      _proxyFuture([ "ping" ], () => _client.ping());

  Future<BucketProps> getBucketProps(String bucket) =>
      _proxyFuture([ "getBucketProps", bucket ],
          () => _client.getBucketProps(bucket));

  Future<Response> setBucketProps(String bucket, BucketProps props) =>
      _proxyFuture([ "setBucketProps", bucket ],
          () => _client.setBucketProps(bucket, props));

  Future<Response<Object>> fetch(FetchRequest req) =>
      _proxyFuture([ "fetch", req.bucket ], () => _client.fetch(req));

  Future<Response> delete(DeleteRequest req) =>
      _proxyFuture([ "delete", req.bucket ], () => _client.delete(req));

  Future<Response<Object>> store(StoreRequest req) =>
      _proxyFuture([ "store", req.bucket ], () => _client.store(req));

  Stream<String> listBuckets() =>
      _proxyStream([ "listBuckets" ], () => _client.listBuckets());

  Stream<String> listKeys(String bucket) =>
      _proxyStream([ "listKeys", bucket ], () => _client.listKeys(bucket));

  Stream<String> queryIndex(IndexRequest req) =>
      _proxyStream([ "queryIndex", req.bucket, req.index ],
          () => _client.queryIndex(req));

  Future<Response<int>> fetchCounter(FetchCounterRequest req) =>
      _proxyFuture([ "fetchCounter", req.bucket ],
          () => _client.fetchCounter(req));

  Future<Response<int>> incrementCounter(IncrementCounterRequest req) =>
      _proxyFuture([ "incrementCounter", req.bucket ],
          () => _client.incrementCounter(req));
}

// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of riak_client;

/** Riak Client */
abstract class Client {

  /** Ping the server and returns OK if server is up and working */
  Future<Response> ping();

  /** Creates a new Bucket object */
  Bucket getBucket(String bucket, { Resolver resolver }) =>
      new Bucket(this, bucket, resolver: _resolver(bucket, resolver));

  /** List all the buckets. Might be a slow operation on large Riak setups. */
  Stream<String> listBuckets();

  /**
   * List all the keys inside a bucket.
   * Might be a slow operation on large Riak setups.
   */
  Stream<String> listKeys(String bucket);

  /** Get the bucket properties. */
  Future<BucketProps> getBucketProps(String bucket);

  /**
   * Set the bucket properties. Only the non-null properties will be set.
   * To reset the bucket properties to the default values, use props=null.
   */
  Future<Response> setBucketProps(String bucket, BucketProps props);

  /** Fetch an object. */
  Future<Response<Object>> fetch(FetchRequest req);

  /** Store or update an object. */
  Future<Response<Object>> store(StoreRequest req);

  /** Delete an object. */
  Future<Response> delete(DeleteRequest req);

  /**
   * Query an index and list the keys.
   * Might be a slow operation on large Riak setups.
   */
  Stream<String> queryIndex(IndexRequest req);

  /** Returns the counter's value. */
  Future<Response<int>> fetchCounter(FetchCounterRequest req);

  /** Increments the counter's value with the specified amount. */
  Future<Response> incrementCounter(IncrementCounterRequest req);

  /** Creates a new client based on the Riak HTTP API. */
  factory Client.http(String host, int port) => new _HttpClient(host, port);

  var _resolverProvider;
  Client._(Resolver resolverProvider(String bucket)) {
    this._resolverProvider = resolverProvider;
  }

  Resolver _resolver(String bucket, Resolver provided) {
    if (provided != null) {
      return provided;
    }
    if (_resolverProvider != null) {
      return _resolverProvider(bucket);
    }
    return null;
  }
}

/**
 * Bucket object to simplify the bucket-relative operations and reduce the
 * repetition of the bucket name.
 */
class Bucket {

  /** Reference to the client that is associated with the bucket. */
  final Client client;

  /** The bucket's name.  */
  final String name;

  /** The bucket's conflict resolver */
  final Resolver resolver;

  Bucket(this.client, this.name, { this.resolver });

  /** Get the bucket properties. */
  Future<BucketProps> getProps() =>
      client.getBucketProps(name);

  /**
   * Set the bucket properties. Only the non-null properties will be set.
   * To reset the bucket properties to the default values, use props=null.
   */
  Future<Response> setProps(BucketProps props) =>
      client.setBucketProps(name, props);

  /** Fetch an object. */
  Future<Response<Object>> fetch(String key,
      { Quorum quorum, Resolver resolver, String ifNotVtag,
        DateTime ifModifiedSince }) =>
            client.fetch(new FetchRequest(name, key,
                quorum: quorum, resolver: _resolver(resolver),
                ifNotVtag: ifNotVtag, ifModifiedSince: ifModifiedSince ));

  /** Store or update an object. */
  Future<Response<Object>> store(String key, Content content,
      { String vclock, Quorum quorum, bool returnBody, Resolver resolver,
        bool ifNew, String ifVtag, DateTime ifUnmodifiedSince }) =>
            client.store(new StoreRequest(name, key, content, vclock: vclock,
                quorum: quorum , returnBody: returnBody,
                resolver: _resolver(resolver), ifNew: ifNew, ifVtag: ifVtag,
                ifUnmodifiedSince: ifUnmodifiedSince));

  /** Delete an object. */
  Future<Response> delete(String key, { String vclock, Quorum quorum }) =>
      client.delete(new DeleteRequest(name, key, vclock:vclock, quorum:quorum));

  /**
   * List all the keys inside the bucket.
   * Might be a slow operation on large Riak setups.
   */
  Stream<String> listKeys() => client.listKeys(name);

  /**
   * Creates a new Index object that references to an _int index.
   */
  Index<int> getIntIndex(String name) =>
      new Index.int(client, this, name);

  /**
   * Creates a new Index object that references to a _bin index.
   */
  Index<String> getStringIndex(String name) =>
      new Index.string(client, this, name);

  /**
   * Creates a new Index object that references the built-in $key index.
   */
  Index<String> getKeyIndex() => getStringIndex("\$key");

  /** Creates a new Counter object. */
  Counter getCounter(String counter) =>
      new Counter(client, this, counter);

  /** Returns the counter's value. */
  Future<Response<int>> fetchCounter(String counter) =>
      client.fetchCounter(new FetchCounterRequest(this.name, counter));

  /** Increments the counter's value with the specified amount. */
  Future<Response> incrementCounter(
      String counter, { int amount: 1 }) =>
          client.incrementCounter(
              new IncrementCounterRequest(this.name, counter, amount));

  /** Decrements the counter's value with the specified amount. */
  Future<Response> decrementCounter(
      String counter, { int amount: 1 }) =>
          incrementCounter(counter, amount: -amount);

  Resolver _resolver(Resolver provided) =>
      provided != null ? provided : this.resolver;
}

/**
 * Read-only Object header, without the content information.
 *
 * This is used instead of Object in cases where we don't want to ever call the
 * mutate operations (store / delete), e.g. during conflict resolution.
 */
abstract class ObjectHeader {

  /** The bucket's name. */
  String get bucketName;

  /** The entry's key. */
  String get key;

  /** The vector clock value as returned by the server. */
  String get vclock;

  /** The version tag (HTTP ETag) of the object. */
  String get vtag;

  /** The last modified timestamp. */
  DateTime get lastModified;
}

/**
 * Describes the value of an entry in a given point in time (vclock + content).
 * Although the content's JSON data is still mutable, the changes are not pushed
 * back to the server, only with the explicit store call.
 */
class Object implements ObjectHeader {

  /** Reference to the bucket that is associated with the object. */
  final Bucket bucket;

  /** The entry's key. */
  final String key;

  /** The vector clock value as returned by the server. */
  final String vclock;

  /** The content of the entry. */
  final Content content;

  /** The version tag (HTTP ETag) of the object. */
  final String vtag;

  /** The last modified timestamp. */
  final DateTime lastModified;

  /** The bucket's name. */
  String get bucketName => bucket.name;

  /** Reference to the client that is associated with the object. */
  Client get client     => bucket.client;

  Object(this.bucket, this.key, this.vclock, this.content, this.vtag,
      this.lastModified);

  /** Conditionally reloads the entry with the vtag. */
  Future<Response<Object>> reload() =>
      bucket.fetch(key, ifNotVtag: vtag);

  /** Delete the entry (and use the vclock to reference the version). */
  Future<Response> delete({ Quorum quorum }) =>
      bucket.delete(key, vclock:vclock, quorum:quorum);

  /** Update the entry (and use the vclock to reference the version). */
  Future<Response<Object>> store(Content content,
      { Quorum quorum, bool returnBody, Resolver resolver,
        bool ignoreChanges: false }) =>
            bucket.store(key, content,
                vclock: vclock, quorum: quorum, returnBody: returnBody,
                resolver: resolver,
                ifVtag: (ignoreChanges ? null : vtag),
                ifUnmodifiedSince: (ignoreChanges ? null : lastModified));
}

/**
 * Describes a secondary index to simplify query operations and reduce the
 * repetition of bucket and index names.
 */
class Index<T> {

  /** Reference to the client that is associated with the index. */
  final Client client;

  /** Reference to the bucket that is associated with the index. */
  final Bucket bucket;

  /** The name of the index (with the _type postfix). */
  final String name;

  Index.string(this.client, this.bucket, String name) :
    this.name = "${name}_bin";

  Index.int(this.client, this.bucket, String name) :
    this.name = "${name}_int";

  /**
   * Query index for exact value match.
   * Might be a slow operation on large Riak setups.
   */
  Stream<String> queryEquals(T value) =>
      client.queryIndex(new IndexRequest(bucket.name, name, value));

  /**
   * Query index for range match.
   * Might be a slow operation on large Riak setups.
   */
  Stream<String> queryRange(T start, T end) =>
      client.queryIndex(new IndexRequest(bucket.name, name, start, end));
}

/** Collection of the bucket properties. */
class BucketProps {

  /** Number of replicas. (Riak's n_val field). */
  final int replicas;

  /**
   * Allow multiple versions of an entry. Requires conflict-resolution.
   * (Riak's allow_mult field.)
   */
  final bool allowSiblings;

  /**
   * Ignores vector clock, uses timestamp to elect conflict-winner instead.
   * (Riak's last_write_wins field.)
   */
  final bool lastWriteWins;

  /** Quorum settings. */
  final Quorum quorum;

  BucketProps({
    this.replicas, this.allowSiblings, this.lastWriteWins, this.quorum });
}

/** Quorum settings for various operations. */
class Quorum {
  static const String ALL    = "all";
  static const String QUORUM = "quorum";
  static const String ONE    = "one";

  final dynamic rw;
  final dynamic r;
  final dynamic w;
  final dynamic pr;
  final dynamic pw;
  final dynamic dw;

  /** Riak's basic_quorum field. */
  final bool basicQuorum;

  /** Riak's not_found_ok field. */
  final bool notFoundIsSuccess;

  Quorum({ this.rw, this.r, this.w, this.pr, this.pw, this.dw,
    this.basicQuorum, this.notFoundIsSuccess });

  factory Quorum.delete({
    dynamic rw, dynamic replicas,
    dynamic r,  dynamic read,
    dynamic w,  dynamic write,
    dynamic pr, dynamic primaryRead,
    dynamic pw, dynamic primaryWrite,
    dynamic dw, dynamic durableWrite
  }) => new Quorum(
    rw : _or(rw, replicas),
    r  : _or(r,  read),
    w  : _or(w,  write),
    pr : _or(pr, primaryRead),
    pw : _or(pw, primaryWrite),
    dw : _or(dw, durableWrite));

  factory Quorum.fetch({
    dynamic r,  dynamic read,
    dynamic pr, dynamic primaryRead,
    bool basic_quorum,
    bool not_found_ok
  }) => new Quorum(
    r  : _or(r,  read),
    pr : _or(pr, primaryRead),
    basicQuorum: basic_quorum,
    notFoundIsSuccess: not_found_ok);

  factory Quorum.store({
    dynamic w, dynamic write,
    dynamic dw, dynamic durableWrite,
    dynamic pw, dynamic primaryWrite
  }) => new Quorum(
    w  : _or(w,  write),
    pw : _or(pw, primaryWrite),
    dw : _or(dw, durableWrite));

  factory Quorum.bucket({
    dynamic rw, dynamic replicas,
    dynamic r,  dynamic read,
    dynamic w,  dynamic write,
    dynamic dw, dynamic durableWrite
  }) => new Quorum(
    rw : _or(rw, replicas),
    r  : _or(r,  read),
    w  : _or(w,  write),
    dw : _or(dw, durableWrite));

  static int valueOf(int replicas, dynamic quorum) {
    switch (quorum) {
      case ALL:
        return replicas;
      case QUORUM:
        return (replicas / 2).floor() + 1;
      case ONE:
        return 1;
      return quorum;
    }
  }

  static _or(dynamic code, dynamic alias) => code == null ? alias : code;
}

/**
 * Counters are a CRDT (convergent replicated data type) that eventually
 * converge to the correct total.
 */
class Counter {

  /** Reference to the client that is associated with the counter. */
  final Client client;

  /** Reference to the bucket that is associated with the counter. */
  final Bucket bucket;

  /** The name of the counter. */
  final String name;

  Counter(this.client, this.bucket, this.name);

  /** Returns the counter's value. */
  Future<Response<int>> fetch() =>
      bucket.fetchCounter(name);

  /** Increments the counter's value with the specified amount. */
  Future<Response> increment({ int amount: 1 }) =>
      bucket.incrementCounter(name, amount: amount);

  /** Decrements the counter's value with the specified amount. */
  Future<Response> decrement({ int amount: 1 }) =>
      increment(amount: -amount);
}

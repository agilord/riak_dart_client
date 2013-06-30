// Copyright (c) 2012-2013, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of riak_client;

/** Common response object with optional result value. */
class Response<R> {
  final int code;
  final bool success;
  final R result;

  Response(this.code, this.success, [ this.result ]);
}

// Request objects.

class DeleteRequest {
  final String bucket;
  final String key;
  final String vclock;
  final Quorum quorum;

  DeleteRequest(this.bucket, this.key, { this.vclock, this.quorum });
}

class FetchRequest {
  final String bucket;
  final String key;
  final Quorum quorum;
  final Resolver resolver;

  /*
  final String vclock;
  bool head;*/

  FetchRequest(this.bucket, this.key,
      { /* this.vclock, */ this.quorum, this.resolver });
}

class StoreRequest {
  final String bucket;
  final String key;
  final Content content;
  final String vclock;
  final Quorum quorum;
  final bool returnBody;
  final Resolver resolver;

  StoreRequest(this.bucket, this.key, this.content,
      { this.vclock, this.quorum, this.returnBody, this.resolver });
}

class IndexRequest {
  final String bucket;
  final String index;
  final dynamic start;
  final dynamic end;

  IndexRequest.string(this.bucket, String index, String start, [String end]):
    this.index = "${index}_bin",
    this.start = start,
    this.end   = end;

  IndexRequest.int(this.bucket, String index, int start, [int end]):
    this.index = "${index}_int",
    this.start = start,
    this.end   = end;

  IndexRequest(this.bucket, this.index, this.start, [this.end]);
}

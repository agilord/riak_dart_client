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

  DeleteRequest(this.bucket, this.key,
      {
        /**
         * The vclock of the previously read value.
         */
        this.vclock,

        /**
         * The requested quorum if not using the bucket's default values.
        */
        this.quorum });
}

class FetchRequest {
  final String bucket;
  final String key;
  final Quorum quorum;
  final Resolver resolver;
  final String ifNotVtag;
  final DateTime ifModifiedSince;

  /*
  final String vclock;
  bool head;*/

  FetchRequest(this.bucket, this.key,
      {
        /**
         * The requested quorum if not using the bucket's default values.
         */
        this.quorum,

        /**
         * Conflict resolver - if the fetched object might have siblings.
         * Will use the bucket's resolver if not specified.
         */
        this.resolver,

        /**
         * Fetch the entry only if the content has changed since the previously
         * read vtag value.
         */
        this.ifNotVtag,

        /**
         * Fetch the entry only if the content has changed since the specified
         * date.
         */
        this.ifModifiedSince });
}

class StoreRequest {
  final String bucket;
  final String key;
  final Content content;
  final String vclock;
  final Quorum quorum;
  final bool returnBody;
  final Resolver resolver;
  final bool ifNew;
  final String ifVtag;
  final DateTime ifUnmodifiedSince;

  StoreRequest(this.bucket, this.key, this.content,
      {
        /**
         * The vclock of the previously read value.
         */
        this.vclock,

        /**
         * The requested quorum if not using the bucket's default values.
         */
        this.quorum,

        /**
         * Should return the stored object?
         */
        this.returnBody: false,

        /**
         * Conflict resolver - if the stored object might have siblings.
         * Will use the bucket's resolver if not specified.
         */
        this.resolver,

        /**
         * Store only if there is no other entry with this key.
         */
        this.ifNew,

        /**
         * Update the entry only if the content has the previously read vtag
         * value (== unchanged)
         */
        this.ifVtag,

        /**
         * Update the entry only if the content is not modified since the
         * specified date.
         */
        this.ifUnmodifiedSince });
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

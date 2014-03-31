// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of riak_client;

class _HttpClient extends Client {
  static final String HEADER_VCLOCK = "X-Riak-Vclock";

  _Cluster _cluster = new _Cluster("cluster");

  _HttpClient(String host, int port,
      { Resolver resolverProvider(String bucket) })
      : super._(resolverProvider) {
    _cluster.join(new Node(host, httpPort: port));
  }

  Future close() =>
      _cluster.close();

  Future<Response> delete(DeleteRequest req) {
    var c = new Completer();
    var params = _quorum(req.quorum);
    _request(c, "delete",
        "/buckets/${_uri(req.bucket)}/keys/${_uri(req.key)}", params)
      .then((HttpClientRequest request) {
        if (req.vclock != null) {
          request.headers.set(HEADER_VCLOCK, req.vclock);
        }
        return request.close();
      })
      .then((HttpClientResponse response) {
        int code = response.statusCode;
        bool success =
            code == HttpStatus.NO_CONTENT ||
            code == HttpStatus.NOT_FOUND;
        c.complete(new Response(code, success));
      })
      .catchError((e, st) {
        c.completeError(e, st);
      });
    return c.future;
  }

  Future<Response<Object>> fetch(FetchRequest req,
      { String vtag, String type: "keys" }) {
    var c = new Completer();
    var params = _quorum(req.quorum);
    // TODO: Decide if vtag can be part of the normal fetch request. If it does,
    //       we shall expose the HttpStatus.MULTIPLE_CHOICES content somehow.
    if (vtag != null) {
      params = params == null ? new Map() : params;
      params["vtag"] = vtag;
    }
    _request(c, "get",
        "/buckets/${_uri(req.bucket)}/$type/${_uri(req.key)}", params)
      .then((HttpClientRequest request) {
        if (req.ifNotVtag != null) {
          request.headers.set(HttpHeaders.IF_NONE_MATCH, req.ifNotVtag);
        }
        if (req.ifModifiedSince != null) {
          request.headers.set(HttpHeaders.IF_MODIFIED_SINCE,
              _formatLastModified(req.ifModifiedSince));
        }
        return request.close();
      })
      .then(HttpBodyHandler.processResponse)
      .then((HttpClientResponseBody body) {
        // TODO: return conn
        _extractFromBody(c, req.bucket, req.key, body, req.resolver);
      })
      .catchError((e, st) {
        c.completeError(e, st);
      });
    return c.future;
  }

  // TODO: find a better place for the date(format) methods
  static DateFormat LAST_MODIFIED_DATEFORMAT =
      new DateFormat("EEE, dd MMM yyyy HH:mm:ss zzz");
  // TODO: remove this after timezone formatting is implemented in intl
  static DateFormat LAST_MODIFIED_DATEFORMAT_WITHOUT_TZ =
      new DateFormat("EEE, dd MMM yyyy HH:mm:ss");

  _getLastModified(HttpHeaders headers) {
    String text = headers.value(HttpHeaders.LAST_MODIFIED);
    if (text != null) {
      try {
        return LAST_MODIFIED_DATEFORMAT.parse(text, true);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  _formatLastModified(DateTime lastModified) =>
   "${ LAST_MODIFIED_DATEFORMAT_WITHOUT_TZ.format(lastModified.toUtc()) } UTC";

  _extractFromBody(Completer c, String bucket, String key,
      HttpClientResponseBody body, Resolver resolver) {
    int statusCode = body.response.statusCode;
    var contentType = body.response.headers.contentType;
    bool success =
        statusCode == HttpStatus.OK ||
        statusCode == HttpStatus.NOT_MODIFIED;

    Object result = null;
    String vclock = body.response.headers.value(HEADER_VCLOCK);
    String etag = body.response.headers.value(HttpHeaders.ETAG);
    DateTime lastmod = _getLastModified(body.response.headers);

    if (statusCode == HttpStatus.NOT_MODIFIED) {
      result = new Object(_bucket(bucket), key, vclock, null, etag, lastmod);
      c.complete(new Response(statusCode, success, result));
    } else if (statusCode == HttpStatus.OK) {
      Content content = null;
      if (body.type == "text") {
        content = new Content.text(body.body, type: contentType);
      } else if (body.type == "json") {
        content = new Content.json(body.body);
      } else if (body.type == "binary") {
        content = new Content.stream(
            new Stream.fromIterable(body.body), type: contentType);
      }
      result = new Object(_bucket(bucket), key, vclock, content, etag, lastmod);
      c.complete(new Response(statusCode, success, result));
    } else if (statusCode == HttpStatus.MULTIPLE_CHOICES) {
      if (resolver == null) {
        resolver = Resolver.DEFAULT;
      }
      Set<String> vtags = new Set();
      try {
        String s;
        body.body.split(new RegExp("\\s+")).forEach((String line) {
          if (line.isNotEmpty && line != "Siblings:") {
            vtags.add(line);
          }
        });
      } catch (e, st) {
        c.completeError(e, st);
        return;
      }

      StreamController siblings = new StreamController(sync: true);
      vtags.forEach((vtag) {
        fetch(new FetchRequest(bucket, key, resolver: resolver), vtag: vtag)
          .then((Response response) {
            if (response.success) {
              siblings.add(response.result);
              vtags.remove(vtag);
              if (vtags.isEmpty) {
                siblings.close();
              }
            } else {
              siblings.addError("Unable to fetch sibling: $vtag");
              siblings.close();
            }
          })
          .catchError((e, st) {
            siblings.addError(e, st);
            siblings.close();
          });
      });

      var contentCompleter = new Completer<Content>();
      resolver.resolve(siblings.stream, contentCompleter);
      contentCompleter.future.then((Content content) {
        // TODO: call store directly and pass resolver
        getBucket(bucket).store(key, content, vclock: vclock, returnBody: true)
          .then((Response<Object> response) {
            c.complete(response);
          })
          .catchError((e, st) {
            c.completeError(e, st);
          });
      }).catchError((e, st) {
        c.completeError(e, st);
      });
    } else {
      c.complete(new Response(statusCode, success));
    }
  }

  Future<Response<Object>> store(StoreRequest req,
      { String type: "keys", String method: "put" }) {
    var c = new Completer();
    var params = _quorum(req.quorum);
    bool returnBody = req.returnBody != null && req.returnBody;
    if (returnBody) {
      params = params == null ? new Map() : params;
      params["returnbody"] = "true";
    }
    String path = req.key == null ?
        "/buckets/${_uri(req.bucket)}/$type" :
        "/buckets/${_uri(req.bucket)}/$type/${_uri(req.key)}";
    Future f = _request(c, method, path, params)
      .then((HttpClientRequest request) {
        request.headers.contentType = req.content.type;
        if (req.vclock != null) {
          request.headers.set(HEADER_VCLOCK, req.vclock);
        }
        if (req.ifVtag != null) {
          request.headers.set(HttpHeaders.IF_MATCH, req.ifVtag);
        }
        if (req.ifUnmodifiedSince != null) {
          request.headers.set(HttpHeaders.IF_UNMODIFIED_SINCE,
              _formatLastModified(req.ifUnmodifiedSince));
        }
        if (req.ifNew != null && req.ifNew) {
          request.headers.set(HttpHeaders.IF_NONE_MATCH, "*");
        }
        if (req.content.header != null) {
          _mapHeaderMeta(request.headers, req.content.header, "X-Riak-Meta-");
        }
        if (req.content.index != null) {
          _mapHeaderMeta(request.headers, req.content.index, "X-Riak-Index-");
        }
        if (req.content.format.isText) {
          // request.encoding = Encoding.UTF_8;
          request.write(req.content.asText);
          return request.close();
        } else if (req.content.format.isJson) {
          // request.encoding = Encoding.UTF_8;
          request.write(JSON.encode(req.content.asJson));
          return request.close();
        } else if (req.content.format.isStream) {
          return req.content.asStream.pipe(request);
        } else {
          throw "unknown format";
        }
      })
      .then((HttpClientResponse response) {
        int code = response.statusCode;
        bool success =
            code == HttpStatus.OK ||
            code == HttpStatus.CREATED ||
            code == HttpStatus.NO_CONTENT;
        if (!returnBody) {
          c.complete(new Response(code, success));
          return null;
        } else {
          return HttpBodyHandler.processResponse(response);
        }
      });
    f.catchError((e, st) {
      c.completeError(e, st);
    });
    if (returnBody) {
      f.then((HttpClientResponseBody body) {
        if (req.returnBody) {
          _extractFromBody(c, req.bucket, req.key, body, req.resolver);
        } else {
          int code = body.response.statusCode;
          bool success =
              code == HttpStatus.OK ||
              code == HttpStatus.CREATED ||
              code == HttpStatus.NO_CONTENT;
          c.complete(new Response(code, success));
        }
      })
      .catchError((e, st) {
        c.completeError(e, st);
      });
    }
    return c.future;
  }

  _mapHeaderMeta(HttpHeaders headers, MetaData meta, String prefix) {
    for (Iterator<String> kiter = meta.getKeys(); kiter.moveNext();) {
      String key = kiter.current;
      List<String> list = new List();
      for (Iterator<String> viter = meta.getValues(key); viter.moveNext();) {
        list.add(viter.current);
      }
      headers.set("${prefix}$key", list.join(","));
    }
  }

  Future<Response> ping() {
    var c = new Completer();
    _request(c, "get", "/ping")
      .then((HttpClientRequest request) => request.close())
      .then((HttpClientResponse response) {
        int code = response.statusCode;
        bool success = code == HttpStatus.OK;
        c.complete(new Response(code, success));
      })
      .catchError((e, st) {
        c.completeError(e, st);
      });
    return c.future;
  }

  Stream<String> listBuckets() {
    var sc = new StreamController<String>.broadcast();
    _requestForStream(sc, "get", "/buckets?buckets=true")
      .then((HttpClientRequest request) => request.close())
      .then(HttpBodyHandler.processResponse)
      .then((HttpClientResponseBody body) {
        body.body["buckets"].forEach((b) {
          sc.add(b);
        });
        sc.close();
      })
      .catchError((e, st) {
        sc.addError(e, st);
        sc.close();
      });
    return sc.stream;
  }

  Stream<String> listKeys(String bucket) {
    var sc = new StreamController<String>.broadcast();
    // TODO: implement stream processing with "?keys=stream"
    _requestForStream(sc, "get", "/buckets/${_uri(bucket)}/keys?keys=true")
      .then((HttpClientRequest request) => request.close())
      .then(HttpBodyHandler.processResponse)
      .then((HttpClientResponseBody body) {
        body.body["keys"].forEach((b) {
          sc.add(b);
        });
        sc.close();
      })
      .catchError((e, st) {
        sc.addError(e, st);
        sc.close();
      });
    return sc.stream;
  }

  Future<Response> setBucketProps(String bucket, BucketProps props) {
    var c = new Completer();
    bool isDelete = props == null;
    _request(c,
        isDelete ? "delete" : "put",
        "/buckets/${_uri(bucket)}/props")
    .then((HttpClientRequest request) {
      if (isDelete) {
        // nothing special here
      } else {
        // request.encoding = Encoding.UTF_8;
        request.headers.contentType = MediaType.JSON;
        Map m = _nonNullMap({
          'n_val'     : props.replicas,
          'allow_mult': props.allowSiblings,
          'last_write_wins': props.lastWriteWins
        });
        if (props.quorum != null) {
          m = _nonNullMap({
            'rw': props.quorum.rw,
            'r':  props.quorum.r,
            'w':  props.quorum.w,
            'dw': props.quorum.dw
          }, m);
        }
        request.write(JSON.encode({ 'props': m }));
      }
      return request.close();
    })
    .then((HttpClientResponse response) {
      int code = response.statusCode;
      bool success = code == HttpStatus.NO_CONTENT;
      c.complete(new Response(code, success));
    })
    .catchError((e, st) {
      c.completeError(e, st);
    });
    return c.future;
  }

  Future<BucketProps> getBucketProps(String bucket) {
    var c = new Completer();
    _request(c, "get", "/buckets/${_uri(bucket)}/props")
      .then((HttpClientRequest request) => request.close())
      .then(HttpBodyHandler.processResponse)
      .then((HttpClientResponseBody body) {
        Map m = body.body['props'];
        c.complete(new BucketProps(
            replicas:      m['n_val'],
            allowSiblings: m['allow_mult'],
            lastWriteWins: m['last_write_wins'],
            quorum: new Quorum.bucket(
                rw: m['rw'],
                r:  m['r'],
                w:  m['w'],
                dw: m['dw'])
            ));
      })
      .catchError((e, st) {
        c.completeError(e, st);
      });
    return c.future;
  }

  Stream<String> queryIndex(IndexRequest req) {
    var sc = new StreamController<String>.broadcast();
    var path = "/buckets/${_uri(req.bucket)}/index/${req.index}/${req.start}";
    if (req.end != null) {
      path = "$path/${req.end}";
    }
    _requestForStream(sc, "get", path)
      .then((HttpClientRequest request) => request.close())
      .then(HttpBodyHandler.processResponse)
      .then((HttpClientResponseBody body) {
        body.body["keys"].forEach((k) {
          sc.add(k);
        });
        sc.close();
      })
      .catchError((e, st) {
        sc.addError(e, st);
        sc.close();
      });
    return sc.stream;
  }

  Future<Response<int>> fetchCounter(FetchCounterRequest req) {
    var c = new Completer();
    var f = fetch(new FetchRequest(req.bucket, req.counter), type: "counters");
    f.then((response) {
      var result = null;
      if (response.success) {
        result = int.parse(response.result.content.asText);
      }
      c.complete(new Response(response.code, response.success, result));
    })
    .catchError((e, st) {
      c.completeError(e, st);
    });
    return c.future;
  }

  Future<Response> incrementCounter(IncrementCounterRequest req) {
    var c = new Completer();
    var f = store(new StoreRequest(req.bucket, req.counter,
        new Content.text(req.amount.toString())),
        type: "counters", method: "post");
    f.then((response) {
      c.complete(new Response(response.code, response.success));
    })
    .catchError((e, st) {
      c.completeError(e, st);
    });
    return c.future;
  }

  Future<HttpClientRequest> _requestForStream(
      StreamController sc, String method, String path, [Map params]) {
    Completer c = new Completer();
    sc.stream.listen((_) {}, onDone: () {
      c.complete(null);
    }, onError: (e, st) {
      c.completeError(e, st);
    });
    return _request(c, method, path, params);
  }

  Future<HttpClientRequest> _request(
      Completer c, String method, String path, [Map params]) {
    return _cluster._httpPool.openUrl(method: method, path: path,
        queryParameters: params, releaseOn: c.future);
  }

  Bucket _bucket(String name) {
    return new Bucket(this, name);
  }

  _quorum(Quorum q, [ Map map ]) {
    if (q == null) {
      return null;
    }
    Map m = {
      "rw" : q.rw,
      "r"  : q.r,
      "w"  : q.w,
      "pr" : q.pr,
      "pw" : q.pw,
      "dw" : q.dw,
      "basic_quorum" : q.basicQuorum,
      "not_found_ok" : q.notFoundIsSuccess
    };
    return _nonNullMap(m, map);
  }

  Map _nonNullMap(Map m, [Map map]) {
    if (map == null) {
      map = new Map();
    }
    m.forEach((String k, v) {
      if (v != null) {
        map[k] = v.toString();
      }
    });
    return map;
  }
}

String _uri(String u) => Uri.encodeComponent(u);

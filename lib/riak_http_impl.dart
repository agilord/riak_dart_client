// Copyright (c) 2012-2013, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of riak;

class _HttpClient extends Client {
  static final String HEADER_VCLOCK = "X-Riak-Vclock";

  final String host;
  final int port;

  HttpClient _client = new HttpClient();

  _HttpClient(this.host, this.port) : super._();

  Future<Response> delete(DeleteRequest req) {
    var c = new Completer();
    var params = _quorum(req.quorum);
    _openUri("delete",
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
      .catchError((e) {
        c.completeError(e);
      });
    return c.future;
  }

  Future<Response<Object>> fetch(FetchRequest req) {
    var c = new Completer();
    var params = _quorum(req.quorum);
    _openUri("get",
        "/buckets/${_uri(req.bucket)}/keys/${_uri(req.key)}", params)
      .then((HttpClientRequest request) {
        // TODO: implement multipart header for conflict resolution
        // request.headers.set(HttpHeaders.ACCEPT, "multipart/mixed");
        return request.close();
      })
      .then(HttpBodyHandler.processResponse)
      .then((HttpClientResponseBody body) {
        int code = body.statusCode;
        bool success =
            code == HttpStatus.OK ||
            code == HttpStatus.NOT_MODIFIED;

        var result = _extractFromBody(req.bucket, req.key, body);
        c.complete(new Response(code, success, result));
      })
      .catchError((e) {
        c.completeError(e);
      });
    return c.future;
  }

  Object _extractFromBody(String bucket, String key, HttpClientResponseBody body) {
    Object result = null;
    if (body.statusCode == HttpStatus.OK) {
      String vclock = body.headers.value(HEADER_VCLOCK);
      Content content = null;
      if (body.type == "text") {
        content = new Content.text(body.body, type:body.contentType);
      } else if (body.type == "json") {
        content = new Content.json(body.body);
      } else if (body.type == "binary") {
        content = new Content.stream(
            new Stream.fromIterable(body.body),
            type:body.contentType);
      }
      result = new Object(_bucket(bucket), key, vclock, content);
    }
    return result;
  }

  Future<Response<Object>> store(StoreRequest req) {
    var c = new Completer();
    var params = _quorum(req.quorum);
    bool returnBody = req.returnBody != null && req.returnBody;
    if (returnBody) {
      params = params == null ? new Map() : params;
      params["returnbody"] = "true";
    }
    String path = req.key == null ?
        "/buckets/${_uri(req.bucket)}/keys" :
        "/buckets/${_uri(req.bucket)}/keys/${_uri(req.key)}";
    Future f = _openUri("put", path, params)
      .then((HttpClientRequest request) {
        request.headers.contentType = req.content.type;
        if (req.vclock != null) {
          request.headers.set(HEADER_VCLOCK, req.vclock);
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
          request.write(json.stringify(req.content.asJson));
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
          return;
        } else {
          return HttpBodyHandler.processResponse(response);
        }
      });
    f.catchError((e) {
      c.completeError(e);
    });
    if (returnBody) {
      f.then((HttpClientResponseBody body) {
        int code = body.statusCode;
        bool success =
            code == HttpStatus.OK ||
            code == HttpStatus.CREATED ||
            code == HttpStatus.NO_CONTENT;

        var result = null;
        if (req.returnBody) {
          result = _extractFromBody(req.bucket, req.key, body);
        }
        c.complete(new Response(code, success, result));
      })
      .catchError((e) {
        c.completeError(e);
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
    _openUri("get", "/ping")
      .then((HttpClientRequest request) => request.close())
      .then((HttpClientResponse response) {
        int code = response.statusCode;
        bool success = code == HttpStatus.OK;
        c.complete(new Response(code, success));
      })
      .catchError((e) {
        c.completeError(e);
      });
    return c.future;
  }

  Stream<String> listBuckets() {
    var sc = new StreamController<String>();
    _openUri("get", "/buckets?buckets=true")
      .then((HttpClientRequest request) => request.close())
      .then(HttpBodyHandler.processResponse)
      .then((HttpClientResponseBody body) {
        body.body["buckets"].forEach((b) {
          sc.add(b);
        });
        sc.close();
      })
      .catchError((e) {
        sc.addError(e);
      });
    return sc.stream;
  }

  Stream<String> listKeys(String bucket) {
    var sc = new StreamController<String>();
    // TODO: implement stream processing with "?keys=stream"
    _openUri("get", "/buckets/${_uri(bucket)}/keys?keys=true")
      .then((HttpClientRequest request) => request.close())
      .then(HttpBodyHandler.processResponse)
      .then((HttpClientResponseBody body) {
        body.body["keys"].forEach((b) {
          sc.add(b);
        });
        sc.close();
      })
      .catchError((e) {
        sc.addError(e);
      });
    return sc.stream;
  }

  Future<Response> setBucketProps(String bucket, BucketProps props) {
    var c = new Completer();
    bool isDelete = props == null;
    _openUri(
        isDelete ? "delete" : "put",
        "/buckets/${_uri(bucket)}/props")
    .then((HttpClientRequest request) {
      if (isDelete) {
        // nothing special here
      } else {
        // request.encoding = Encoding.UTF_8;
        request.headers.contentType = MediaType.JSON;
        Map m = _nonNullMap({
          'n_val'     : props.n_val,
          'allow_mult': props.allow_mult,
          'last_write_wins': props.last_write_wins
        });
        if (props.quorum != null) {
          m = _nonNullMap({
            'rw': props.quorum.rw,
            'r':  props.quorum.r,
            'w':  props.quorum.w,
            'dw': props.quorum.dw
          }, m);
        }
        request.write(json.stringify({ 'props': m }));
      }
      return request.close();
    })
    .then((HttpClientResponse response) {
      int code = response.statusCode;
      bool success = code == HttpStatus.NO_CONTENT;
      c.complete(new Response(code, success));
    })
    .catchError((e) {
      c.completeError(e);
    });
    return c.future;
  }

  Future<BucketProps> getBucketProps(String bucket) {
    var c = new Completer();
    _openUri("get", "/buckets/${_uri(bucket)}/props")
      .then((HttpClientRequest request) => request.close())
      .then(HttpBodyHandler.processResponse)
      .then((HttpClientResponseBody body) {
        Map m = body.body['props'];
        c.complete(new BucketProps(
            n_val:      m['n_val'],
            allow_mult: m['allow_mult'],
            last_write_wins: m['last_write_wins'],
            quorum: new Quorum.bucket(
                rw: m['rw'],
                r:  m['r'],
                w:  m['w'],
                dw: m['dw'])
            ));
      })
      .catchError((e) {
        c.completeError(e);
      });
    return c.future;
  }

  Stream<String> queryIndex(IndexRequest req) {
    var sc = new StreamController<String>();
    var path = "/buckets/${_uri(req.bucket)}/index/${req.index}/${req.start}";
    if (req.end != null) {
      path = "$path/${req.end}";
    }
    _openUri("get", path)
      .then((HttpClientRequest request) => request.close())
      .then(HttpBodyHandler.processResponse)
      .then((HttpClientResponseBody body) {
        body.body["keys"].forEach((k) {
          sc.add(k);
        });
        sc.close();
      })
      .catchError((e) {
        sc.addError(e);
      });
    return sc.stream;
  }

  Future<HttpClientRequest> _openUri(String method, String path, [Map params]) {
    return _client.openUrl(method,
        new Uri(scheme:"http", host: host, port: port, path: path,
            queryParameters: params));
  }

  Bucket _bucket(String name) {
    return new Bucket(this, name);
  }

  _quorum(Quorum q, [ Map map ]) {
    if (q == null) {
      return;
    }
    Map m = {
      "rw" : q.rw,
      "r"  : q.r,
      "w"  : q.w,
      "pr" : q.pr,
      "pw" : q.pw,
      "dw" : q.dw,
      "basic_quorum" : q.basic_quorum,
      "not_found_ok" : q.not_found_ok
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

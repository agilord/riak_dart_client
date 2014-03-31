// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

part of riak_client;

/** A Riak endpoint */
class Node {

  final String host;
  final int httpPort;
  final int pbPort;

  Endpoint _httpEndpoint;
  Endpoint _pbEndpoint;

  Node(this.host, {this.httpPort: 8098, this.pbPort: 8087}) {
    assert(httpPort != null || pbPort != null);
    _httpEndpoint = httpPort == null ? null : new Endpoint(host, httpPort);
    _pbEndpoint = pbPort == null ? null : new Endpoint(host, pbPort);
  }

  bool operator ==(Node other) =>
      host == other.host &&
      httpPort == other.httpPort &&
      pbPort == other.pbPort;

  int get hashCode =>
      host.hashCode + httpPort * 13 + pbPort * 11;
}

/** A Riak cluster with multiple [Node]s. */
class _Cluster {

  final String name;
  List<Node> _nodes = [];
  HttpClientPool _httpPool;
  SocketPool _pbPool;

  _Cluster(this.name) {
    _httpPool = new HttpClientPool();
    _pbPool = new SocketPool();
  }

  void join(Node node) {
    if (_nodes.contains(node)) {
      return;
    }
    if (node._httpEndpoint != null) {
      _httpPool.join(node._httpEndpoint);
    }
    if (node._pbEndpoint != null) {
      _pbPool.join(node._pbEndpoint);
    }
    _nodes.add(node);
  }

  void leave(Node node) {
    if (!_nodes.contains(node)) {
      return;
    }
    if (node._httpEndpoint != null) {
      _httpPool.leave(node._httpEndpoint);
    }
    if (node._pbEndpoint != null) {
      _pbPool.leave(node._pbEndpoint);
    }
    _nodes.remove(node);
  }

  Future close() {
    return Future.wait([_httpPool.close(), _pbPool.close()]);
  }
}

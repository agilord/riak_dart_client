
# riak-dart-client

Riak database client, written in Dart.

## Features

Available Riak functionality:
- Fetch, store and delete objects (with vclock conditionals)
- Store and query secondary index
- Get and set bucket properties

Dart client design goals:
- Meaningful wrapper objects
- Immutable structures (exception: JSON content, but changes won't be pushed)

## Roadmap

0.6
- conflict resolution of multiple entries (allow_mult)
- CRDT (commutative replicated data type) example
- configurable retry-on-failure

0.7
- robust stream handling (e.g. what to do on backend failure, re-start?)
- non-buffered HTTP response processing
- pooling client (simple round-robin)
- mock backend for testing (in-memory and filesystem)

0.8
- map-reduce support
- link-walking support
- list-resources support

0.9
- protobuf client implementation
- mixed client (protobuf / http, based on the request)
- search support

1.0
- stable API
- pool monitoring and stats

The order might vary, depending on the contributor's requirements. If you would
like to add something, contact us (see AUTHORS or pubspec file).

## References

- Riak: http://basho.com/riak/
- Dart: http://dartlang.org/

- Main site: http://code.google.com/p/riak-dart/
- GitHub mirror: https://github.com/agilord/riak-dart-client/

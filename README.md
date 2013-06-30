
# Riak Dart client

Riak database client, written in Dart.

## Features

Available Riak functionality:
- fetch, store and delete objects (with vclock conditionals)
- store and query secondary index
- get and set bucket properties
- resolve conflicts if multiple parallel write produces siblings

Dart client design goals:
- Meaningful wrapper objects
- Immutable structures (exception: JSON content, but changes won't be pushed)

## Roadmap

0.6
- conflict resolution of multiple entries (allow_mult)
- CRDT (commutative replicated data type) example
- ETag, Not-Modified-Since support

0.7
- configurable retry-on-failure
- robust stream handling (e.g. what to do on backend failure, re-start?)
- non-buffered HTTP response processing
- pooling client (simple round-robin)

0.8
- map-reduce support
- link-walking support
- list-resources support
- mock backend for testing (in-memory and filesystem)

0.9
- protobuf client implementation
- mixed client (protobuf / http, based on the request)
- search support

1.0
- stable API
- pool monitoring and stats

The order might vary, depending on the contributor's requirements. If you would
like to add something, contact us (see AUTHORS or pubspec file).

## Migration guide

0.4 -> 0.5
- full API changed

0.5 -> 0.6
- no breaking change (yet)

## References

- Riak: http://basho.com/riak/
- Dart: http://dartlang.org/

- Main site: http://code.google.com/p/riak-dart/
- GitHub mirror: https://github.com/agilord/riak_dart_client/

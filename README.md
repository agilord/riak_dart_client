
# Riak Dart client

Riak database client, written in Dart.

## Features

Available Riak functionality:
- fetch, store and delete objects (with vclock, vtag and last modified preconditions)
- store and query secondary index
- get and set bucket properties
- resolve conflicts if parallel writes produce siblings
- counters (fetch, increment/decrement)

Dart client design goals:
- Meaningful wrapper objects
- Immutable structures (exception: JSON content, but changes won't be pushed)

## Roadmap

0.7
- map-reduce support
- link-walking support
- list-resources support

0.8
- protobuf client implementation
- mixed client (protobuf / http, based on the request)
- search support

0.9
- mock backend for testing (in-memory and filesystem)
- configurable retry-on-failure
- robust stream handling (e.g. what to do on backend failure, re-start?)
- non-buffered HTTP response processing
- pooling client (simple round-robin)

1.0
- stable API
- pool monitoring and stats

The order might vary, depending on the contributor's requirements. If you would
like to add something, contact us (see AUTHORS or pubspec file).

## Migration guide

0.4 -> 0.5
- full API changed

0.5 -> 0.6
- Renamed BucketProps's fields to follow the Dart conventions (n_val ->
  replicas, allow_mult -> allowSiblings, last_write_wins -> lastWriteWins).
- Renamed Quorum's fields to follow the Dart conventions (basic_quorum ->
  basicQuorum, not_found_ok -> notFoundIsSuccess).

## References

- Riak: http://basho.com/riak/
- Dart: http://dartlang.org/

- Main site: http://code.google.com/p/riak-dart/
- GitHub mirror: https://github.com/agilord/riak_dart_client/

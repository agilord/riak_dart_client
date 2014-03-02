
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

## Usage Examples

Create an HTTP client and target a bucket:

```dart
Client client = new Client.http('127.0.0.1', 10017);
Bucket exampleBucket = client.getBucket('example');
```

Fetch a text object:

```dart
String exampleKey = 'text_example_key';

exampleBucket.fetch(exampleKey).then((Response value) {
  String text = value.result.content.asText;
  ... do something with text ...
});
```

Fetch a JSON object:

```dart
String exampleKey = 'json_example_key';

exampleBucket.fetch(exampleKey).then((Response value) {
  Map json = value.result.content.asJson;
  ... do something with JSON ...
});
```

Store a text object:

```dart
String key = 'text_message';
String message = 'hello from the Dart server';
Content content = new Content.text(message);

exampleBucket.store(key, content).then((Response response) {
  ... do something with response ...
});
```

Store a JSON object:

```dart
String key = 'json_message';
Map json = { 'foo': 'bar' };
Content content = new Content.json(json);

exampleBucket.store(key, content).then((Response response) {
  ... do something with response ...
});
```

List all buckets (not recommended in production environments):

```dart
List<String> bucketNames = new List<String>();

client.listBuckets().listen((String bucketName) {
  bucketNames.add(bucketName);
});

print(bucketNames);
```

List all keys in a bucket (also not recommended in production environments):

```dart
List<String> keyNames = new List<String>();

bucket.listKeys().listen((String keyName) {
  keyNames.add(keyName);
});

print(keyNames);
```

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

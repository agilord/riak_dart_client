// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

library riak_test;

import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:unittest/unittest.dart';

import 'package:riak_client/riak_client.dart' as riak;
part 'local_http_test.dart';

main(List<String> args) {
  TestConfig config = new TestConfig.args(args);

  new LocalHttpTest(config).run();
}

class TestConfig {

  String httpHost   = "127.0.0.1";
  int    httpPort   = 8098;
  String bucket     = "test";
  bool   keepData   = false;
  bool   skipDataCheck = false;

  /// The directory containing the test script being run.
  Directory get directory => new File(Platform.script.path).parent;

  TestConfig();
  TestConfig.args(List<String> arguments) {
    var parser = new ArgParser();
    parser.addOption(
        'http-host', defaultsTo: '$httpHost',
        help: 'The HTTP hostname for local testing.');
    parser.addOption(
        'http-port', defaultsTo: '$httpPort',
        help: 'The HTTP port for local testing.');
    parser.addOption(
        'bucket', defaultsTo: '$bucket',
        help: 'The bucket to store the test entries.');
    parser.addFlag(
        'keep-data',
        help: 'Set this to true to prevent data from being deleted '
              'at the end of the successful tests.');
    parser.addFlag(
        'skip-data-check',
        help: 'Set this to true if buckets with data exist before tests run.');
    parser.addFlag('help', help: 'This help message.',
        callback: (help) {
          if (help) {
            print('Usage:');
            print(parser.getUsage());
            exit(0);
          }
        });
    ArgResults results = parser.parse(arguments);
    httpHost = results['http-host'];
    httpPort = int.parse(results['http-port']);
    bucket = results['bucket'];
    keepData = results['keep-data'];
    skipDataCheck = results['skip-data-check'];
    // print("Test config: $httpHost, $httpPort, $bucket, $keepData, $skipDataCheck");
  }
}

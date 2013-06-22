library riak_test;

import 'dart:async';
import 'dart:io';
import 'package:args/args.dart';
import 'package:unittest/unittest.dart';

import 'package:riak/riak.dart' as riak;
part 'local_http_test.dart';

main() {
  TestConfig config = new TestConfig.args(new Options().arguments);

  new LocalHttpTest(config).run();
}

class TestConfig {

  String httpHost   = "127.0.0.1";
  int    httpPort   = 8098;
  String bucket     = "test";
  bool   keepData   = false;

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
        help: 'Set this to true to prevent data to be deleted '
              'at the end of the successful tests.');
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
    // print("Test config: $httpHost, $httpPort, $bucket, $keepData");
  }
}

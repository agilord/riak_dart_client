// Copyright (c) 2012-2014, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// version:       0.6.1+
// last-modified: 2014-02-11

library riak_client;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http_server/http_server.dart';
import 'package:intl/intl.dart';

import 'protos/riak.pb.dart';
import 'protos/riak_kv.pb.dart';
import 'protos/riak_search.pb.dart';

import 'ext/pool/connection_pool.dart';

part 'cluster.dart';

/* core API classes */
part 'riak_api_base.dart';

/* content-related API classes */
part 'riak_api_content.dart';

/* auxilliary API classes */
part 'riak_api_messages.dart';

/* HTTP client implementation */
part 'riak_http_impl.dart';

/* Protobuf client implementation */
part 'riak_protobuf_impl.dart';

/* Monitoring proxy client implementation */
part 'riak_monitor_impl.dart';

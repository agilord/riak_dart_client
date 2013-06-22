// Copyright (c) 2012-2013, the Riak-Dart project authors (see AUTHORS file).
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

// version:       0.5.0
// last-modified: 2013-06-22

library riak;

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:json' as json;

/* core API classes */
part 'riak_api_base.dart';

/* content-related API classes */
part 'riak_api_content.dart';

/* auxilliary API classes */
part 'riak_api_messages.dart';

/* HTTP client implementation */
part 'riak_http_impl.dart';

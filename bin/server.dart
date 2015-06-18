// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:github_hook/github_hook.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main(List<String> args) {
  var parser = new ArgParser()
    ..addOption('port', abbr: 'p', defaultsTo: '8080')
    ..addOption('secret', abbr: 's');

  var result = parser.parse(args);

  var port = int.parse(result['port'], onError: (val) {
    print('Could not parse port value "$val" into a number.');
    exit(1);
  });

  var secret = result['secret'];

  if (secret == null) {
    print('A secret must be provided');
    print('See https://developer.github.com/v3/repos/hooks/#create-a-hook');
    exit(1);
  }

  var handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(createGitHubHookMiddleware(secret, _echoRequest));

  io.serve(handler, 'localhost', port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
}

Future<Null> _echoRequest(HookRequest request) async {
  print(request);
}

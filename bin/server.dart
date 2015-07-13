// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:appengine/appengine.dart' as ae;
import 'package:github_hook/github_hook.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_appengine/shelf_appengine.dart' as shelf_ae;

import 'package:github_email_notify/api.dart';

main() async {
  ae.useLoggingPackageAdaptor();

  var secret = getEnvValue('github_secret');

  var githubHandler = createEventHandler();
  var githubHookHandler = createGitHubHookMiddleware(secret, githubHandler);

  var cascade = new Cascade().add((Request request) async {
    if (request.headers.containsKey('x-github-delivery')) {
      return githubHookHandler(request);
    }

    var segs = request.url.pathSegments;

    if (segs.isNotEmpty && segs.first == apiRoot) {
      return _apiHandler(request.change(path: apiRoot));
    }

    if (segs.isNotEmpty && segs.length == 1 && segs.single == 'triage') {
      var uri = await dartSdkNoAreaIssues;

      return new Response.seeOther(uri);
    }

    return new Response.notFound('Sorry – ${request.requestedUri}');
  }).add(shelf_ae.assetHandler(
      directoryIndexServeMode: shelf_ae.DirectoryIndexServeMode.SERVE));

  var handler =
      const Pipeline().addMiddleware(logRequests()).addHandler(cascade.handler);

  await shelf_ae.serve(handler);
}

Future<Response> _apiHandler(Request request) async {
  var segments = request.url.pathSegments;

  var jsonResponse;
  if (segments.isEmpty) {
    jsonResponse = await rootObject();
  } else if (request.method == 'POST' && segments.length == 1) {
    try {
      jsonResponse = await _handleApiPost(request);
    } catch (e, stack) {
      // TODO: might could use custom error object w/ human-readable things...
      var dateLog = logError('Bad post', e, stack);
      return new Response.internalServerError(
          body: _encodeObject(
              {'message': 'Bad post', 'timestamp': dateLog.toIso8601String()}),
          headers: _jsonHeaders);
    }
  }

  if (jsonResponse != null) {
    return new Response.ok(_encodeObject(jsonResponse), headers: _jsonHeaders);
  }

  return _getErrorResponse("Not sure what you're trying to do there...");
}

Future<Map> _handleApiPost(Request request) async {
  assert(request.method == 'POST');

  var apiEndpoint = request.url.pathSegments.single;

  switch (apiEndpoint) {
    case emailAuthPath:
      var authCode = await request.readAsString();
      var email = await authenticateUserWithAuthCode(authCode);
      return <String, String>{'email': email};
    case emailAuthLogoutPath:
      await forgetEmailSender();
      return {'status': 'all forgotten'};
    case sendTestMessagePath:
      await sendTestEmail();
      return {'status': 'email sent!'};
    case updateGithubLabelsPath:
      await updateGithubLabels();
      return {'status': 'updated!'};
    default:
      throw "Not sure how to party on $apiEndpoint";
  }
}

Response _getErrorResponse(String errorMessage) {
  var errorJson = {'error': errorMessage};

  return new Response.internalServerError(
      headers: _jsonHeaders, body: _encodeObject(errorJson));
}

final _jsonUtf8 = new JsonUtf8Encoder(' ');

Stream<List<int>> _encodeObject(json) {
  return _jsonUtf8.bind(new Stream.fromIterable([json]));
}

const _jsonHeaders = const {'content-type': 'application/json; charset=utf-8'};

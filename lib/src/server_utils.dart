library api.server_utils;

import 'dart:io';

import 'package:appengine/appengine.dart' as ae;
import 'package:firebase/firebase_io.dart';
import 'package:path/path.dart' as p;
import 'package:stack_trace/stack_trace.dart';

DateTime logError(String message, [error, StackTrace stack]) {
  var buffer = new StringBuffer();

  buffer.writeln(message);

  if (error != null) {
    buffer.writeln(error.runtimeType);
    buffer.writeln(error);
  }

  if (stack != null) {
    var chain = new Chain.forTrace(stack);
    buffer.writeln(chain.terse);
  }

  var date = new DateTime.now().toUtc();

  ae.loggingService.error(buffer.toString(), timestamp: date);

  return date;
}

String get senderEmailAccount => getEnvValue('senderEmailAccount');

String get clientIdentifier => getEnvValue('clientIdentifier');

String get clientSecret => getEnvValue('clientSecret');

String get appName => getEnvValue('appName');

String get githubToken => getEnvValue('githubToken');

String get githubRepo => getEnvValue('githubRepo');

String get firebaseSecret => getEnvValue('firebaseSecret');

String get firebaseDomain => getEnvValue('firebaseDomain');

String getLabelsPath(String repoFullName) =>
    p.url.join('repos', encodeKey(repoFullName), 'labels');

Uri getLabelsUri(String repoFullName) => new Uri(
    scheme: 'https',
    host: firebaseDomain,
    path: '${getLabelsPath(repoFullName)}.json');

Uri getUsersForRepoUri(String repoFullName) => new Uri(
    scheme: 'https',
    host: firebaseDomain,
    path: p.url.join('repos', encodeKey(repoFullName), 'users.json'));

String getMyLabelsPath(String userEmail, String repoFullName) =>
    p.url.join('repos', encodeKey(repoFullName), 'users', encodeKey(userEmail));

String getFirebaseSecurityToken(String userEmail) =>
    createFirebaseJwtToken(firebaseSecret, data: {'uid': encodeKey(userEmail)});

String getEnvValue(String key) {
  var value = Platform.environment[key];

  if (value == null) {
    throw new StateError('"$key" must be defined in app.yaml');
  }

  return value;
}

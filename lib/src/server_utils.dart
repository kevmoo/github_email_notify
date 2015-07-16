library api.server_utils;

import 'package:appengine/appengine.dart' as ae;
import 'package:firebase/firebase_io.dart';
import 'package:path/path.dart' as p;
import 'package:stack_trace/stack_trace.dart';

import 'environment_variable_access.dart';

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

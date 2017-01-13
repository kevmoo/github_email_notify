library api.src.datastore;

import 'dart:async';
import 'dart:convert';

import 'package:firebase/firebase_io.dart';

import 'environment_variable_access.dart';
import 'server_utils.dart';

Future<Null> syncGitHubLabels(
    String repoFullName, Iterable<String> labels) async {
  var map = new Map.fromIterable(labels,
      key: (i) => encodeKey(i), value: (i) => true);

  var theUri = getLabelsUri(repoFullName);

  await _client.put(theUri, map);
}

Future<Iterable<String>> getGithubLabels(String repoFullName) async {
  var theUri = getLabelsUri(repoFullName);

  Map<String, bool> encodedLabelsMap = await _client.get(theUri) ?? const {};

  return encodedLabelsMap.keys.map((i) => decodeKey(i));
}

Future<Null> writeAuthCreds(credsJson) async {
  await _client.put(credsUri, JSON.encode(credsJson));
}

Future<dynamic> readAuthCreds() async {
  var credsString = await _client.get(credsUri);

  if (credsString == null) return null;

  return JSON.decode(credsString);
}

Future<Null> deleteAuthCreds() async {
  await _client.delete(credsUri);
}

final _client = new FirebaseClient(firebaseSecret);

const _credsKey = 'email_creds';

final credsUri =
    new Uri(scheme: 'https', host: firebaseDomain, path: '${_credsKey}.json');

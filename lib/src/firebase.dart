library api.src.datastore;

import 'dart:async';

import 'package:firebase/firebase_io.dart';

import 'server_utils.dart';

Future<Null> syncGitHubLabels(
    String repoFullName, Iterable<String> labels) async {
  var map = new Map.fromIterable(labels,
      key: (i) => encodeKey(i), value: (i) => true);

  var fbClient = new FirebaseClient(firebaseSecret);

  var theUri = getLabelsUri(repoFullName);

  await fbClient.put(theUri, map);
}

library api.github_event_handler;

import 'dart:async';

import 'package:appengine/appengine.dart' as ae;
import 'package:firebase/firebase_io.dart';
import 'package:github_hook/github_hook.dart';
import 'package:memcache/memcache.dart';

import 'gmail.dart';
import 'server_utils.dart';

Memcache get _memcache => ae.context.services.memcache;

GitHubRequestHandler createEventHandler() {
  return _echoRequest;
}

Future<Null> _echoRequest(HookRequest request) async {
  if (request is IssuesHookRequest) {
    if (request.action == 'labeled') {
      await _handleLabeledEvent(request);
    }
  }

  print(request);

  var key = 'event-${request.githubEvent}';

  String allKeysString = await _memcache.get('all-event-keys');

  if (allKeysString != null) {
    var allKeys = allKeysString.split(',').toSet();
    allKeys.removeWhere((k) => k.isEmpty);
    allKeys.add(key);
    allKeysString = allKeys.join(',');
  } else {
    allKeysString = key;
  }

  await _memcache.set('all-event-keys', allKeysString);

  await _memcache.increment(key);
}

Future<Null> _handleLabeledEvent(IssuesHookRequest request) async {
  assert(request.action == 'labeled');

  assert(request.label != null);

  var client = new FirebaseClient(firebaseSecret);

  var labeledRepository = request.repository.fullName;

  var labelName = request.label.name;

  var items = await client.get(getUsersForRepoUri(labeledRepository)) as Map;

  if (items == null) {
    return;
  }

  var subscribedEmails = new Set<String>();

  items.forEach((String encodedEmail, Map labelMap) {
    if (labelMap.containsKey(labelName)) {
      var email = decodeKey(encodedEmail);

      // decode the email!
      subscribedEmails.add(email);
    }
  });

  ae.loggingService.info('Sending email to ${subscribedEmails.toString()}.');

  var subject =
      '${request.repository.fullName}#${request.issue.number} labeled ${request.label.name} by ${request.sender.user}';

  var body = '''
Issue: ${request.issue.githubUrl}
Title: ${request.issue.title}
Label: ${request.label.name}
 User: ${request.sender.user} - ${request.sender.githubUrl}
''';

  await sendEmail(subject, body, bccEmails: subscribedEmails);
}

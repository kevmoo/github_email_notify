library api.github_event_handler;

import 'dart:async';

import 'package:appengine/appengine.dart' as ae;
import 'package:firebase/firebase_io.dart';
import 'package:github_hook/github_hook.dart';

import 'gmail.dart';
import 'server_utils.dart';

GitHubRequestHandler createEventHandler() {
  return _echoRequest;
}

Future<Null> _echoRequest(HookRequest request) async {
  if (request is IssuesHookRequest) {
    if (request.action == 'labeled') {
      await _handleLabeledEvent(request);
    }
  }
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
 User: ${request.sender.user} - ${request.sender.githubUrl}
Label: ${request.label.name}

${request.issue.githubUrl}
${request.issue.title}

${request.issue.body}
''';

  await sendEmail(subject, body, bccEmails: subscribedEmails);
}

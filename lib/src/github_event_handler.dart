library api.github_event_handler;

import 'dart:async';

import 'package:firebase/firebase_io.dart';
import 'package:github_hook/github_hook.dart';
import 'package:logging/logging.dart';

import 'environment_variable_access.dart';
import 'gmail.dart';
import 'server_utils.dart';

Future<Null> githubRequestHandler(HookRequest request) async {
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

  var message = 'Issue ${request.issue.number}, label "$labelName"';

  if (subscribedEmails.isEmpty) {
    Logger.root.info('$message – no subscriptions.');
    return;
  }

  Logger.root
      .info('$message – sending email to ${subscribedEmails.join(', ')}.');

  var subject =
      "[+${request.label.name}]: ${request.issue.title} (${request.repository.fullName}#${request.issue.number})";

  var body = '''
 User: ${request.sender.user} - ${request.sender.githubUrl}
Label: ${request.label.name}

${request.issue.githubUrl}
${request.issue.title}

${request.issue.body}
''';

  await sendEmail(subject, body, bccEmails: subscribedEmails);
}

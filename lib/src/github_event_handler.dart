library api.github_event_handler;

import 'dart:async';

import 'package:firebase/firebase_io.dart';
import 'package:github_hook/github_hook.dart';

import 'environment_variable_access.dart';
import 'gmail.dart';
import 'logging.dart';
import 'mime_email.dart';
import 'server_utils.dart';

Future<Null> githubRequestHandler(HookRequest request) async {
  if (request is IssuesHookRequest) {
    if (request.action == 'labeled') {
      await _handleLabeledEvent(request);
      return;
    }
  }
  logger.info('Nothing to do with this GitHub event: ${request.githubEvent}.\n'
      'Content: ${_flattenMap(request.content).join(', ')}');
}

Future<Null> _handleLabeledEvent(IssuesHookRequest request) async {
  assert(request.action == 'labeled');

  assert(request.label != null);
  var labeledRepository = request.repository.fullName;

  var labelName = request.label.name.toLowerCase();

  logger.info(
      'Repository: ${labeledRepository} issue ${request.issue.number} labeled ${labelName}.');

  var client = new FirebaseClient(firebaseSecret);

  var items = await client.get(getUsersForRepoUri(labeledRepository)) as Map;

  if (items == null) {
    logger.info('No users for repo: $labeledRepository.');
    return;
  }

  var subscribedEmails = new Set<String>();

  items.forEach((String encodedEmail, Map<String, dynamic> labelMap) {
    if (labelMap.keys.any((k) => k.toLowerCase() == labelName)) {
      var email = decodeKey(encodedEmail);

      // decode the email!
      subscribedEmails.add(email);
    }
  });

  var message = 'Issue ${request.issue.number}, label "$labelName"';

  if (subscribedEmails.isEmpty) {
    logger.info('$message – no subscriptions.');
    return;
  }

  logger.info('$message – sending email to ${subscribedEmails.join(', ')}.');

  var content = createLabelEmailContent(
      appName,
      senderEmailAccount,
      subscribedEmails,
      request.label.name,
      request.repository.fullName,
      request.sender.user,
      request.sender.githubUrl,
      request.issue.number,
      request.issue.title,
      request.issue.githubUrl,
      request.issue.body,
      request.issue.user.user,
      request.issue.user.githubUrl);

  await sendEmail(content);
}

Iterable<String> _flattenMap(Map input) sync* {
  for (var key in input.keys) {
    var val = input[key];
    if (val != null && val is! Map) {
      yield '$key: $val';
    }
  }
}

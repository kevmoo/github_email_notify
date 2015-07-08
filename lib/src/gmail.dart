library api.src.gmail;

import 'dart:async';
import 'dart:convert';

import 'package:googleapis/gmail/v1.dart';

import 'email_sender_credentials.dart';
import 'server_utils.dart';

Future<Message> sendEmail(String toEmail, String subject, {String body}) async {
  var fromLine = '$appName <$senderEmailAccount>';

  if (body == null) {
    body = '';
  }

  var emailContent = '''mime-version: 1.0
Subject: $subject
From: $fromLine
To: $toEmail
Content-Type: text/plain; charset=UTF-8

$body''';

  var request = new Message()..rawAsBytes = UTF8.encode(emailContent);

  Message sentMessage;
  await withAuthenticatedClient((client) async {
    var api = new GmailApi(client);

    sentMessage = await api.users.messages.send(request, senderEmailAccount);
  });

  print([
    sentMessage.historyId,
    sentMessage.id,
    sentMessage.labelIds,
    sentMessage.payload,
    sentMessage.snippet
  ]);

  return sentMessage;
}

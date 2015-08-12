library api.src.gmail;

import 'dart:async';
import 'dart:convert';

import 'package:googleapis/gmail/v1.dart';
import 'package:logging/logging.dart';

import 'email_sender_credentials.dart';
import 'environment_variable_access.dart';

Future<Message> sendEmail(String subject, String body,
    {Iterable<String> toEmails, Iterable<String> bccEmails}) async {
  var fromLine = '$appName <$senderEmailAccount>';

  if (body == null) {
    body = '';
  }

  var emailContent = new StringBuffer()
    ..writeln('mime-version: 1.0')
    ..writeln('Subject: $subject')
    ..writeln('From: $fromLine');

  if (toEmails != null && toEmails.isNotEmpty) {
    emailContent.writeln('To: ${toEmails.join(',')}');
  }

  if (bccEmails != null && bccEmails.isNotEmpty) {
    emailContent.writeln('Bcc: ${bccEmails.join(', ')}');
  }

  emailContent.write('''Content-Type: text/plain; charset=UTF-8

$body''');

  var request = new Message()
    ..rawAsBytes = UTF8.encode(emailContent.toString());

  Message sentMessage;
  await withAuthenticatedClient((client) async {
    var api = new GmailApi(client);

    sentMessage = await api.users.messages.send(request, senderEmailAccount);
  });

  Logger.root.info(
      "Mail ID ${sentMessage.id} – labels: ${sentMessage.labelIds.join(', ')}");

  return sentMessage;
}

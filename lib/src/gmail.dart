library api.src.gmail;

import 'dart:async';
import 'dart:convert';

import 'package:googleapis/gmail/v1.dart';

import 'email_sender_credentials.dart';
import 'environment_variable_access.dart';
import 'logging.dart';

Future<Message> sendEmail(String mimeContent) async {
  var request = new Message()..rawAsBytes = UTF8.encode(mimeContent);

  Message sentMessage;
  await withAuthenticatedClient((client) async {
    var api = new GmailApi(client);

    sentMessage = await api.users.messages.send(request, senderEmailAccount);
  });

  logger.info(
      "Mail ID ${sentMessage.id} – labels: ${sentMessage.labelIds.join(', ')}");

  return sentMessage;
}

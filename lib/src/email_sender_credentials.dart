library api.src.email_sender_credentials;

import 'dart:async';

import 'package:appengine/api/users.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import 'environment_variable_access.dart';
import 'firebase.dart';

final identifier = new auth.ClientId(clientIdentifier, clientSecret);

const noCredsStoredError = 'No creds are stored here, sorry!';

void _requireSenderPermissions() {
  if (userService.currentUser != null && userService.currentUser.isAdmin) {
    // all good!
    return;
  }

  // TODO: it'd be nice if we could restrict this somehow – know that we're
  // coming from a github request – but –you know
}

void requiredAdmin() {
  if (!userService.currentUser.isAdmin) {
    throw new StateError('Muts be an admin, yo!');
  }
}

Future updateCreds(auth.AccessCredentials credentials) async {
  Logger.root.info('Auto-updating providing credentials');

  await writeAuthCreds(_accessCredstoJson(credentials));
}

Future withAuthenticatedClient(Future func(auth.AuthClient client),
    {auth.AccessCredentials creds}) async {
  if (creds == null) {
    creds = await _getStoredSenderEmailCredentials();
  }

  var client = new http.IOClient();
  try {
    var authClient = auth.autoRefreshingClient(identifier, creds, client);

    Future foreachFuture;
    try {
      foreachFuture = authClient.credentialUpdates.asyncMap((item) async {
        await updateCreds(item);
      }).drain();

      return await func(authClient);
    } finally {
      authClient.close();

      if (foreachFuture != null) {
        await foreachFuture;
      }
    }
  } finally {
    client.close();
  }
}

Future<auth.AccessCredentials> _getStoredSenderEmailCredentials() async {
  _requireSenderPermissions();

  var json = await readAuthCreds();

  if (json == null) {
    throw noCredsStoredError;
  }

  return _accessCredsfromJson(json);
}

auth.AccessCredentials _accessCredsfromJson(credsJson) {
  var tokenJson = credsJson['accessToken'];

  var token = new auth.AccessToken(tokenJson['type'], tokenJson['data'],
      DateTime.parse(tokenJson['expiry']));

  return new auth.AccessCredentials(
      token, credsJson['refreshToken'], credsJson['scopes']);
}

dynamic _accessCredstoJson(auth.AccessCredentials creds) => {
      'refreshToken': creds.refreshToken,
      'scopes': creds.scopes,
      'accessToken': {
        'type': creds.accessToken.type,
        'data': creds.accessToken.data,
        'expiry': creds.accessToken.expiry.toIso8601String()
      }
    };

library api.src.email_sender_credentials;

import 'dart:async';
import 'dart:convert';

import 'package:appengine/appengine.dart' as ae;
import 'package:appengine/api/users.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:googleapis/oauth2/v2.dart';
import 'package:gcloud/storage.dart';
import 'package:http/http.dart' as http;

import 'server_utils.dart';
import 'shared.dart';

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

Bucket get bucket {
  requiredAdmin();
  return _bucket;
}

Bucket get _bucket => ae.context.services.storage.bucket(authTokenBucket);

Future updateCreds(auth.AccessCredentials credentials) async {
  ae.loggingService.info('Auto-updating providing credentials');
  var prettyString = prettyJson(_accessCredstoJson(credentials));

  var jsonBites = UTF8.encode(prettyString);
  await _bucket.writeBytes(authTokenFileName, jsonBites,
      contentType: 'application/json');
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

  var json;
  try {
    json = await _bucket
        .read(authTokenFileName)
        .transform(UTF8.decoder)
        .transform(JSON.decoder).single;
  } on DetailedApiRequestError catch (e) {
    if (e.status == 400 || e.status == 404) {
      print("Could not get the email file from storage");
      print(e);
      throw noCredsStoredError;
    } else {
      // 404 is reasonable, anything else – something is broken
      rethrow;
    }
  }

  if (json == null) {
    // Need to prompt the user to authenticate, right?
    return null;
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

String get authTokenFileName => getEnvValue('authTokenFileName');

dynamic _accessCredstoJson(auth.AccessCredentials creds) => {
  'refreshToken': creds.refreshToken,
  'scopes': creds.scopes,
  'accessToken': {
    'type': creds.accessToken.type,
    'data': creds.accessToken.data,
    'expiry': creds.accessToken.expiry.toIso8601String()
  }
};

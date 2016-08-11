library api.admin_logic;

import 'dart:async';

import 'package:appengine/api/users.dart';
import 'package:github/server.dart';
import 'package:googleapis/oauth2/v2.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

import 'email_sender_credentials.dart';
import 'environment_variable_access.dart';
import 'firebase.dart';
import 'gmail.dart';
import 'mime_email.dart';
import 'models.dart';
import 'server_utils.dart';

Future<Null> updateGithubLabels() async {
  var auth = new Authentication.withToken(githubToken);
  var github = createGitHubClient(auth: auth);

  try {
    var slug = new RepositorySlug.full(githubRepo);

    var labels = await github.issues
        .listLabels(slug)
        .map((IssueLabel il) => il.name)
        .toList();

    await syncGitHubLabels(githubRepo, labels);
  } finally {
    github.dispose();
  }
}

Future<String> authenticateUserWithAuthCode(String authCode) async {
  requiredAdmin();

  String email;
  auth.AccessCredentials creds;
  var client = new http.IOClient();
  try {
    creds = await auth.obtainAccessCredentialsViaCodeExchange(
        client, identifier, authCode);

    var authClient = auth.authenticatedClient(client, creds);

    email = await _getAuthorizedEmailCore(authClient);
  } finally {
    client.close();
  }

  if (email == null) {
    throw "Bad email, son!";
  }

  await updateCreds(creds);

  return email;
}

Future sendTestEmail() async {
  requiredAdmin();

  var toEmail = userService.currentUser.email;

  var subject = "Test message from $appName - ${new DateTime.now().toUtc()}";

  var content = createLabelEmailContent(
      appName,
      senderEmailAccount,
      [toEmail],
      "SampleLabel",
      "sample/repo",
      appName,
      Uri.parse("https://www.dartlang.org/"),
      8652,
      subject,
      Uri.parse('https://github.com/dart-lang/sdk/issues/8652'),
      '''
A <strong>user</strong> requested a sample email to be sent from the &quot;site&quot;.

# Here is some markdown

```cool
huh?
```

* 1
* 2
* 3
''',
      toEmail,
      Uri.parse("mailto:$toEmail"));

  await sendEmail(content);
}

Future forgetEmailSender() async {
  await deleteAuthCreds();
}

Future<AdminObject> getAdminObject() async {
  requiredAdmin();

  String authorizedSenderEmail;
  try {
    authorizedSenderEmail = await _getAuthorizedEmail();
  } catch (e) {
    if (e != noCredsStoredError) {
      rethrow;
    }
  }

  return new AdminObject(authorizedSenderEmail, clientIdentifier);
}

Future<String> _getAuthorizedEmail() async {
  return await withAuthenticatedClient((auth.AuthClient client) async {
    return await _getAuthorizedEmailCore(client);
  });
}

Future<String> _getAuthorizedEmailCore(auth.AuthClient authClient) async {
  try {
    // now try to get something w/ it?

    var oauth2Api = new Oauth2Api(authClient);

    Tokeninfo tokenInfo;
    var retryCount = 0;
    do {
      try {
        tokenInfo = await oauth2Api.tokeninfo(
            accessToken: authClient.credentials.accessToken.data);
      } catch (e) {
        if (retryCount > 2) {
          rethrow;
        }
        retryCount++;
      }
    } while (tokenInfo == null);

    var authedSenderEmail = tokenInfo.email;

    if (authedSenderEmail != senderEmailAccount) {
      logError('Bad email!\n'
          'The authenticated sender account – $authedSenderEmail – does not '
          'match the configured "senderEmailAccount" – $senderEmailAccount.');
      return null;
    }

    return authedSenderEmail;
  } catch (e, stack) {
    logError('Colud not get email thingy', e, stack);
    return null;
  }
}

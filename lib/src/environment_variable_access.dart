library api.src.environment_variable_access;

import 'dart:io';

/// Used to format the sender of emails
String get appName => _getEnvValue('appName');

/// Used with [clientSecret] to authenticate the email sender account in the
/// admin flow
String get clientIdentifier => _getEnvValue('clientIdentifier');

/// Used with [clientIdentifier] to authenticate the email sender account in the
/// admin flow
String get clientSecret => _getEnvValue('clientSecret');

/// The Firebase domain used to store user data
String get firebaseDomain => _getEnvValue('firebaseDomain');

/// The Firebase secret that maps to the [firebaseDomain]
String get firebaseSecret => _getEnvValue('firebaseSecret');

/// The GitHub repository that has the labels we care about
String get githubRepo => _getEnvValue('githubRepo');

/// Must match the secret you provide to GitHub for your webhook.
///
/// See https://developer.github.com/webhooks/
String get githubSecret => _getEnvValue('githubSecret');

/// Use for updating GitHub labels. If the repo is public, you can set this to
/// have `ZERO` extra access. Keep it safe.
///
/// See https://github.com/settings/tokens
String get githubToken => _getEnvValue('githubToken');

/// The email address that will send emails for this app
///
/// When the admin authenticates the email account, it MUST match this email.
String get senderEmailAccount => _getEnvValue('senderEmailAccount');

String _getEnvValue(String key) {
  var value = Platform.environment[key];

  if (value == null) {
    throw new StateError('"$key" must be defined in app.yaml');
  }

  return value;
}

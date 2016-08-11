library api.shared;

import 'dart:convert';

import 'package:googleapis/gmail/v1.dart';
import 'package:googleapis/oauth2/v2.dart';

const apiRoot = 'api';
const emailAuthPath = 'email_auth';
const emailAuthLogoutPath = 'email_deauth';
const sendTestMessagePath = 'send_test_message';
const updateGithubLabelsPath = 'update_github_labels';

// This is the list of scopes this application will use.
// You need to enable the Drive API in the Google Developers Console.
const scopes = const [GmailApi.GmailComposeScope, Oauth2Api.UserinfoEmailScope];

String prettyJson(json) => const JsonEncoder.withIndent(' ').convert(json);

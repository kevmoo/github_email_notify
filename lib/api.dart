library api;

import 'dart:async';

import 'package:appengine/api/users.dart';

import 'src/admin_logic.dart';
import 'src/firebase.dart';
import 'src/models.dart';
import 'src/server_utils.dart';

export 'src/admin_logic.dart';
export 'src/github_event_handler.dart';
export 'src/server_utils.dart';
export 'src/shared.dart';

Future<ApiObject> rootObject() async {
  var triageLinks = await _getDartSdkTriageLinks();
  var apiObject = new ApiObject()..triageUris = triageLinks;

  var currentUser = userService.currentUser;
  if (currentUser != null) {
    apiObject.logoutUrl = await userService.createLogoutUrl('/');

    var firebaseBaseUri = 'https://${firebaseDomain}';

    var availableLabelsfirebasePath = getLabelsPath(githubRepo);

    var myLabelsFirebaseUrl = getMyLabelsPath(currentUser.email, githubRepo);

    var firebaseSecurityToken = getFirebaseSecurityToken(currentUser.email);

    apiObject.currentUser = new UserObject(currentUser.email, githubRepo,
        _githubUrlFromRepo(githubRepo), firebaseBaseUri,
        availableLabelsfirebasePath, myLabelsFirebaseUrl,
        firebaseSecurityToken);

    if (currentUser.isAdmin) {
      apiObject.adminObject = await getAdminObject();
    }
  } else {
    apiObject.loginUrl = await userService.createLoginUrl('/');
  }

  return apiObject;
}

String _githubUrlFromRepo(String repo) => 'https://github.com/$repo';

Future<Map<String, String>> _getDartSdkTriageLinks() async {
  var links = <String, String>{};

  var labels = await getGithubLabels(githubRepo);

  var areaLabels =
      labels.where((label) => label.toLowerCase().startsWith('area-'));

  var queryItems = ['is:issue', 'is:open'];

  queryItems.addAll(areaLabels.map((label) => '-label:$label'));

  var query = queryItems.join(' ');

  var triageParams = {'utf': '✓', 'q': query};

  links['Issues without an area'] = new Uri.https(
      'github.com', 'dart-lang/sdk/issues', triageParams).toString();

  return links;
}

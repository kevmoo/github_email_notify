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
  var apiObject = new ApiObject();

  var currentUser = userService.currentUser;
  if (currentUser != null) {
    apiObject.logoutUrl = await userService.createLogoutUrl('/');

    var firebaseBaseUri = 'https://${firebaseDomain}';

    var availableLabelsfirebasePath = getLabelsPath(githubRepo);

    var myLabelsFirebaseUrl = getMyLabelsPath(currentUser.email, githubRepo);

    var firebaseSecurityToken = getFirebaseSecurityToken(currentUser.email);

    var triageLinks = await _getDartSdkTriageLinks();

    apiObject.currentUser = new UserObject(currentUser.email, githubRepo,
        _githubUrlFromRepo(githubRepo), triageLinks, firebaseBaseUri,
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

  var areaLabels = labels.where((label) {
    var lc = label.toLowerCase();
    return lc.startsWith('area-') && lc != 'area-none';
  });

  // https://github.com/dart-lang/sdk/issues?utf8=%E2%9C%93&q=is%3Aissue+is%3Aopen+-label%3Aarea-vm+-label%3Aarea-multi

  var queryItems = ['is:issue', 'is:open'];

  queryItems.addAll(areaLabels.map((label) => '-label:$label'));

  var query = queryItems.join(' ');

  var triageParams = {'utf': '✓', 'q': query};

  links['Issues without an area'] = new Uri.https(
      'github.com', 'dart-lang/sdk/issues', triageParams).toString();

  return links;
}

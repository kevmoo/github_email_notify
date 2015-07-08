library api;

import 'dart:async';

import 'package:appengine/api/users.dart';

import 'src/admin_logic.dart';
import 'src/models.dart';
import 'src/server_utils.dart';

export 'github_hook.dart';
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

    var availableLabelsfirebasePath = getLablesPath(githubRepo);

    var myLabelsFirebaseUrl = getMyLabelsPath(currentUser.email, githubRepo);

    var firebaseSecurityToken = getFirebaseSecurityToken(currentUser.email);

    apiObject.currentUser = new UserObject(currentUser.email, githubRepo,
        firebaseBaseUri, availableLabelsfirebasePath, myLabelsFirebaseUrl,
        firebaseSecurityToken);

    if (currentUser.isAdmin) {
      apiObject.adminObject = await getAdminObject();
    }
  } else {
    apiObject.loginUrl = await userService.createLoginUrl('/');
  }

  return apiObject;
}

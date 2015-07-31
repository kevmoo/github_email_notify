library github_hook.web.index;

import 'dart:convert';

import 'package:googleapis_auth/auth_browser.dart' as auth;

import 'package:stack_trace/stack_trace.dart';

import "package:angular2/bootstrap.dart" show bootstrap;
import "package:angular2/angular2.dart" hide Response;
import "package:angular2/src/reflection/reflection.dart"
    show reflector, ReflectionInfo;
import "package:angular2/src/reflection/reflection_capabilities.dart"
    show ReflectionCapabilities;

import 'package:github_email_notify/browser.dart';
import 'package:http/browser_client.dart';
import 'package:http/http.dart';

import 'user_comp.dart';

@Component(
    selector: "app",
    lifecycle: const [LifecycleEvent.onInit],
    hostInjector: const [BrowserClient])
@View(
    templateUrl: 'client_app.html',
    directives: const [NgIf, NgFor, UserComponent])
class ClientApp {
  final BrowserClient _client;
  auth.BrowserOAuth2Flow _flow;

  bool loginDisabled = true;

  ApiObject root;

  ClientApp(BrowserClient client) : this._client = client;

  void onInit() {
    assert(loginDisabled);
    assert(root == null);
    _refreshData();
  }

  void _refreshData() {
    root = null;
    _client.get('/api').then((response) {
      _onApiRoot(JSON.decode(response.body));
    });
  }

  _onApiRoot(json) async {
    root = new ApiObject.fromJson(json);

    if (root.adminObject != null) {
      final clientId =
          new auth.ClientId(root.adminObject.clientIdentifier, null);

      _flow = await auth.createImplicitBrowserFlow(clientId, scopes,
          baseClient: _client);
      loginDisabled = false;
    }
  }

  login() async {
    if (loginDisabled) return;

    loginDisabled = true;
    try {
      auth.HybridFlowResult result = await _flow.runHybridFlow(force: true);

      var response = await _client.post('/api/$emailAuthPath',
          headers: {'contentType': 'application/octet-stream; charset=utf-8'},
          body: result.authorizationCode);

      _errorHandler(response);

      _refreshData();
    } finally {
      loginDisabled = false;
    }
  }

  emailSenderLogout() async {
    if (loginDisabled) return;

    loginDisabled = true;
    try {
      var response = await _client.post('/api/$emailAuthLogoutPath');

      _errorHandler(response);
      _refreshData();
    } finally {
      loginDisabled = false;
    }
  }

  updateGithubLabels() async {
    if (loginDisabled) return;

    loginDisabled = true;
    try {
      var response = await _client.post('/api/$updateGithubLabelsPath');
      _errorHandler(response);
    } finally {
      loginDisabled = false;
    }
  }

  sendTestMessage() async {
    if (loginDisabled) return;

    loginDisabled = true;
    try {
      var response = await _client.post('/api/$sendTestMessagePath');
      _errorHandler(response);
    } finally {
      loginDisabled = false;
    }
  }
}

_errorHandler(Response response) {
  if (response.statusCode != 200) {
    throw ['Bad response', response.statusCode, response.body].join('\n');
  }
}

main() {
  Chain.capture(() {
    reflector.registerType(BrowserClient,
        new ReflectionInfo(null, null, () => new BrowserClient()));

    reflector.reflectionCapabilities = new ReflectionCapabilities();
    bootstrap(ClientApp);
  }, onError: (error, Chain chain) {
    print(error);
    print(chain.terse);
  });
}

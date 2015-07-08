import 'dart:convert';
import 'dart:io';

import 'package:github_hook/github_hook.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test("IssuesHookRequest parse", () {
    var path = p.join('test', 'json_files', 'github_issues_event.json');

    var str = new File(path).readAsStringSync();

    var jsonMap = JSON.decode(str);

    var issueRequest = new HookRequest('issues',
        'ccd5a280-1c37-11e5-9d84-6974af26189f', jsonMap) as IssuesHookRequest;

    expect(issueRequest.action, 'labeled');

    Issue issue = issueRequest.issue;
    expect(issue.githubUrl,
        Uri.parse('https://github.com/dart-lang/angular2_build/issues/1'));

    var label = issue.labels.single;
    expect(label.name, 'Area-VM');
    expect(label.url, Uri.parse(
        "https://api.github.com/repos/dart-lang/angular2_build/labels/Area-VM"));

    var repo = issueRequest.repository;
    expect(repo.name, 'angular2_build');
    expect(repo.fullName, 'dart-lang/angular2_build');
    expect(repo.githubUrl,
        Uri.parse('https://github.com/dart-lang/angular2_build'));
  });
}

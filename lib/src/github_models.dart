library api.src.github_models;

/*
{
  "login": "kevmoo",
  "id": 17034,
  "avatar_url": "https://avatars.githubusercontent.com/u/17034?v=3",
  "gravatar_id": "",
  "url": "https://api.github.com/users/kevmoo",
  "html_url": "https://github.com/kevmoo",
  "followers_url": "https://api.github.com/users/kevmoo/followers",
  "following_url": "https://api.github.com/users/kevmoo/following{/other_user}",
  "gists_url": "https://api.github.com/users/kevmoo/gists{/gist_id}",
  "starred_url": "https://api.github.com/users/kevmoo/starred{/owner}{/repo}",
  "subscriptions_url": "https://api.github.com/users/kevmoo/subscriptions",
  "organizations_url": "https://api.github.com/users/kevmoo/orgs",
  "repos_url": "https://api.github.com/users/kevmoo/repos",
  "events_url": "https://api.github.com/users/kevmoo/events{/privacy}",
  "received_events_url": "https://api.github.com/users/kevmoo/received_events",
  "type": "User",
  "site_admin": false
}
 */
class User {
  final String user;
  final Uri githubUrl;
  final Uri avatarUrl;

  User(this.user, this.githubUrl, this.avatarUrl);

  factory User.fromJson(Map json) => new User(json['login'],
      Uri.parse(json['html_url']), Uri.parse(json['avatar_url']));
}

/*
{
  "url": "https://api.github.com/repos/dart-lang/angular2_build/labels/Area-VM",
  "name": "Area-VM",
  "color": "5319e7"
}
 */
class Label {
  final Uri url;
  final String name;
  final String color;

  Label(this.url, this.name, this.color);

  factory Label.fromJson(Map<String, dynamic> json, {bool passNull}) {
    if (passNull == true && json == null) {
      return null;
    }

    return new Label(Uri.parse(json["url"]), json["name"], json["color"]);
  }
}

/*
  "repository": {
    "id": 32725453,
    "name": "angular2_build",
    "full_name": "dart-lang/angular2_build",
    "owner": {

    },
    "private": true,
    "html_url": "https://github.com/dart-lang/angular2_build",
    "description": "Kevin's manually managed build output of Angular 2 for Dart team folks who want to look at the generated output",
    "fork": false,
 */
class Repository {
  final String name;
  final String fullName;
  final bool private;
  final Uri githubUrl;

  Repository(this.name, this.fullName, this.private, this.githubUrl);

  factory Repository.fromJson(Map json) => new Repository(json["name"],
      json["full_name"], json["private"], Uri.parse(json["html_url"]));
}

/*
 "issue": {
    "url": "https://api.github.com/repos/dart-lang/angular2_build/issues/1",
    "labels_url": "https://api.github.com/repos/dart-lang/angular2_build/issues/1/labels{/name}",
    "comments_url": "https://api.github.com/repos/dart-lang/angular2_build/issues/1/comments",
    "events_url": "https://api.github.com/repos/dart-lang/angular2_build/issues/1/events",
    "html_url": "https://github.com/dart-lang/angular2_build/issues/1",
    "id": 91308965,
    "number": 1,
    "title": "sample vm issue",
    "user": {
     ...
    },
    "labels": [
      {
       ...
      }
    ],
    "state": "open",
    "locked": false,
    "assignee": null,
    "milestone": null,
    "comments": 0,
    "created_at": "2015-06-26T17:22:15Z",
    "updated_at": "2015-06-26T17:22:15Z",
    "closed_at": null,
    "body": ""
  },
 */
class Issue {
  final Uri githubUrl;
  final String title;
  final int number;
  final List<Label> labels;
  final String state;

  Issue(this.number, this.githubUrl, this.title, this.state, this.labels);

  factory Issue.fromJson(Map json) => new Issue(
      json['number'],
      Uri.parse(json['html_url']),
      json['title'],
      json['state'],
      new List.unmodifiable(json['labels'].map((j) => new Label.fromJson(j))));
}

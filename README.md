*Send emails when GitHub labels change.*

### Getting started

#### Deploy a simple sample app first.

Read through and deploy the [Dart App Engine sample](https://www.dartlang.org/server/google-cloud-platform/app-engine/).
* This is a complex app. If you can't get the sample running, you'll go crazy trying to get all of this up and going.

#### Configure App Engine

* Enable `GMail API`.
* Follow the other instructions for enabling an Dart App Engine app.

#### Configure GitHub

* Enable [GitHub Webhooks](https://developer.github.com/webhooks/) for a
  repository. Make sure that `Issues` events are enabled for the web hook.

#### Configure Firebase

* Create a new project.
* Make sure your security rules are set correctly.

```json
{
  "rules": {
    "repos": {
      "$repo" : {
        "labels": {
          ".read": true
        },
        "users" : {
          "$user_id": {
            ".write": "$user_id === auth.uid",
            ".read": "$user_id === auth.uid"
          }
        }
      }
    }
  }
}
```

#### Update `app.yaml`
* There are **a lot** of services you need to configure.
* Copy `app.sample.yaml` to `app.yaml`.
  * `app.yaml` is explicitly ignored in `.gitignore` to make sure you don't commit a bunch of secrets to a public GitHub repo.
* See `lib/src/environment_variable_access.dart` for details.

### Technologies

* [Dart on Google App Engine](https://www.dartlang.org/server/google-cloud-platform/app-engine/)
* [Angular2 - Dart](https://angular.io/)
* [GitHub Webhooks](https://developer.github.com/webhooks/)
* [Firebase](https://www.firebase.com/)
* [Google APIs: GMail](https://pub.dartlang.org/packages/googleapis)

### Known issues

#### Must comment out `transformers:` section when using Dartium in dev mode

* This is due to a known Angular issue.
* Also why the Angular 2 dependency is locked at `angular2: 2.0.0-alpha.29`.

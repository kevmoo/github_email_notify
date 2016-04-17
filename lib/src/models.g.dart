// GENERATED CODE - DO NOT MODIFY BY HAND

part of api.models;

// **************************************************************************
// Generator: JsonSerializableGenerator
// Target: class AdminObject
// **************************************************************************

AdminObject _$AdminObjectFromJson(Map json) =>
    new AdminObject(json['authorizedEmail'], json['clientIdentifier']);

abstract class _$AdminObjectSerializerMixin {
  String get authorizedEmail;
  String get clientIdentifier;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'authorizedEmail': authorizedEmail,
        'clientIdentifier': clientIdentifier
      };
}

// **************************************************************************
// Generator: JsonSerializableGenerator
// Target: class ApiObject
// **************************************************************************

ApiObject _$ApiObjectFromJson(Map json) => new ApiObject()
  ..triageUris = json['triageUris']
  ..currentUser = json['currentUser'] == null
      ? null
      : new UserObject.fromJson(json['currentUser'])
  ..adminObject = json['adminObject'] == null
      ? null
      : new AdminObject.fromJson(json['adminObject'])
  ..loginUrl = json['loginUrl']
  ..logoutUrl = json['logoutUrl'];

abstract class _$ApiObjectSerializerMixin {
  Map get triageUris;
  UserObject get currentUser;
  AdminObject get adminObject;
  String get loginUrl;
  String get logoutUrl;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'triageUris': triageUris,
        'currentUser': currentUser,
        'adminObject': adminObject,
        'loginUrl': loginUrl,
        'logoutUrl': logoutUrl
      };
}

// **************************************************************************
// Generator: JsonSerializableGenerator
// Target: class UserObject
// **************************************************************************

UserObject _$UserObjectFromJson(Map json) => new UserObject(
    json['email'],
    json['githubRepoName'],
    json['githubRepoUri'],
    json['firebaseBase'],
    json['availableLabelsFirebasePath'],
    json['myLabelsFirebasePath'],
    json['firebaseSecurityToken']);

abstract class _$UserObjectSerializerMixin {
  String get email;
  String get githubRepoName;
  String get githubRepoUri;
  String get firebaseBase;
  String get availableLabelsFirebasePath;
  String get myLabelsFirebasePath;
  String get firebaseSecurityToken;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'email': email,
        'githubRepoName': githubRepoName,
        'githubRepoUri': githubRepoUri,
        'firebaseBase': firebaseBase,
        'availableLabelsFirebasePath': availableLabelsFirebasePath,
        'myLabelsFirebasePath': myLabelsFirebasePath,
        'firebaseSecurityToken': firebaseSecurityToken
      };
}

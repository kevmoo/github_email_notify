// GENERATED CODE - DO NOT MODIFY BY HAND
// 2015-07-06T16:06:16.159Z

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
  ..currentUser = json['currentUser'] == null
      ? null
      : new UserObject.fromJson(json['currentUser'])
  ..adminObject = json['adminObject'] == null
      ? null
      : new AdminObject.fromJson(json['adminObject'])
  ..loginUrl = json['loginUrl']
  ..logoutUrl = json['logoutUrl'];

abstract class _$ApiObjectSerializerMixin {
  UserObject get currentUser;
  AdminObject get adminObject;
  String get loginUrl;
  String get logoutUrl;
  Map<String, dynamic> toJson() => <String, dynamic>{
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

UserObject _$UserObjectFromJson(Map json) => new UserObject(json['email'],
    json['githubRepo'], json['firebaseBase'],
    json['availableLabelsFirebasePath'], json['myLabelsFirebasePath'],
    json['firebaseSecurityToken']);

abstract class _$UserObjectSerializerMixin {
  String get email;
  String get githubRepo;
  String get firebaseBase;
  String get availableLabelsFirebasePath;
  String get myLabelsFirebasePath;
  String get firebaseSecurityToken;
  Map<String, dynamic> toJson() => <String, dynamic>{
    'email': email,
    'githubRepo': githubRepo,
    'firebaseBase': firebaseBase,
    'availableLabelsFirebasePath': availableLabelsFirebasePath,
    'myLabelsFirebasePath': myLabelsFirebasePath,
    'firebaseSecurityToken': firebaseSecurityToken
  };
}

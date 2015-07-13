library api.models;

import 'package:source_gen/generators/json_serializable.dart';

part 'models.g.dart';

@JsonSerializable()
class AdminObject extends Object with _$AdminObjectSerializerMixin {
  final String authorizedEmail;

  /// Used for the auth flow
  final String clientIdentifier;

  AdminObject(this.authorizedEmail, this.clientIdentifier);

  factory AdminObject.fromJson(json) => _$AdminObjectFromJson(json);
}

@JsonSerializable()
class ApiObject extends Object with _$ApiObjectSerializerMixin {
  Map<String, String> triageUris = <String, String>{};

  UserObject currentUser;
  AdminObject adminObject;
  String loginUrl;
  String logoutUrl;

  ApiObject();

  factory ApiObject.fromJson(json) => _$ApiObjectFromJson(json);
}

@JsonSerializable()
class UserObject extends Object with _$UserObjectSerializerMixin {
  final String email;

  final String githubRepoName;
  final String githubRepoUri;

  final String firebaseBase;
  final String availableLabelsFirebasePath;
  final String myLabelsFirebasePath;
  final String firebaseSecurityToken;

  UserObject(this.email, this.githubRepoName, this.githubRepoUri,
      this.firebaseBase, this.availableLabelsFirebasePath,
      this.myLabelsFirebasePath, this.firebaseSecurityToken);

  factory UserObject.fromJson(json) => _$UserObjectFromJson(json);
}

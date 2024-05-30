import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wallet/rust/proton_api/auth_credential.dart';

part 'native.session.model.g.dart';

@JsonSerializable()
class FlutterSession {
  String userId;
  String sessionId;
  String userName;
  String passphrase;
  String accessToken;
  String refreshToken;
  List<String> scopes;

  FlutterSession({
    required this.userId,
    required this.sessionId,
    required this.userName,
    required this.passphrase,
    required this.accessToken,
    required this.refreshToken,
    required this.scopes,
  });

  /// Connect the generated [_$FlutterSessionFromJson] function to the `fromJson`
  /// factory.
  factory FlutterSession.fromJson(Map<String, dynamic> json) =>
      _$FlutterSessionFromJson(json);

  /// Connect the generated [_$FlutterSessionToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$FlutterSessionToJson(this);
}

@JsonSerializable()
class UserInfo {
  final String userId;
  final String userMail;
  final String userName;
  final String userDisplayName;
  final String sessionId;
  final String accessToken;
  final String refreshToken;
  final String scopes;
  final String userKeyID;
  final String userPrivateKey;
  final String userPassphrase;

  UserInfo({
    required this.userId,
    required this.userMail,
    required this.userName,
    required this.userDisplayName,
    required this.sessionId,
    required this.accessToken,
    required this.refreshToken,
    required this.scopes,
    required this.userKeyID,
    required this.userPrivateKey,
    required this.userPassphrase,
  });

  // remove later
  factory UserInfo.from(Map<String, dynamic> userInfo) {
    return UserInfo(
      userId: userInfo["userId"] ?? "",
      userMail: userInfo["userMail"] ?? "",
      userName: userInfo["userName"] ?? "",
      userDisplayName: userInfo["userDisplayName"] ?? "",
      sessionId: userInfo["sessionId"] ?? "",
      accessToken: userInfo["accessToken"] ?? "",
      refreshToken: userInfo["refreshToken"] ?? "",
      scopes: userInfo["scopes"] ?? "",
      userKeyID: userInfo["userKeyID"] ?? "",
      userPrivateKey: userInfo["userPrivateKey"] ?? "",
      userPassphrase: userInfo["userPassphrase"] ?? "",
    );
  }

  factory UserInfo.fromAuth(AuthCredential auth) {
    return UserInfo(
      userId: auth.userId,
      userMail: auth.userMail,
      userName: auth.userName,
      userDisplayName: auth.displayName,
      sessionId: auth.sessionId,
      accessToken: auth.accessToken,
      refreshToken: auth.accessToken,
      scopes: auth.scops.join(","),
      userKeyID: auth.userKeyId,
      userPrivateKey: auth.userPrivateKey,
      userPassphrase: auth.userPassphrase,
    );
  }

  /// Connect the generated [_$UserInfoFromJson] function to the `fromJson`
  /// factory.
  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  /// Connect the generated [_$FlutterSessionToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

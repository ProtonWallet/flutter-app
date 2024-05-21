import 'package:freezed_annotation/freezed_annotation.dart';

part 'native.session.model.g.dart';

@JsonSerializable()
class FlutterSession {
  String userId;
  String sessionId;
  String userName;
  String passphrase;
  String accessToken;
  String refreshToken;

  FlutterSession({
    required this.userId,
    required this.sessionId,
    required this.userName,
    required this.passphrase,
    required this.accessToken,
    required this.refreshToken,
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

  /// Connect the generated [_$UserInfoFromJson] function to the `fromJson`
  /// factory.
  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);

  /// Connect the generated [_$FlutterSessionToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);
}

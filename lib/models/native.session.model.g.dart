// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native.session.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FlutterSession _$FlutterSessionFromJson(Map<String, dynamic> json) =>
    FlutterSession(
      userId: json['userId'] as String,
      sessionId: json['sessionId'] as String,
      userName: json['userName'] as String,
      passphrase: json['passphrase'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$FlutterSessionToJson(FlutterSession instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'sessionId': instance.sessionId,
      'userName': instance.userName,
      'passphrase': instance.passphrase,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };

UserInfo _$UserInfoFromJson(Map<String, dynamic> json) => UserInfo(
      userId: json['userId'] as String,
      userMail: json['userMail'] as String,
      userName: json['userName'] as String,
      userDisplayName: json['userDisplayName'] as String,
      sessionId: json['sessionId'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      scopes: json['scopes'] as String,
      userKeyID: json['userKeyID'] as String,
      userPrivateKey: json['userPrivateKey'] as String,
      userPassphrase: json['userPassphrase'] as String,
    );

Map<String, dynamic> _$UserInfoToJson(UserInfo instance) => <String, dynamic>{
      'userId': instance.userId,
      'userMail': instance.userMail,
      'userName': instance.userName,
      'userDisplayName': instance.userDisplayName,
      'sessionId': instance.sessionId,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
      'scopes': instance.scopes,
      'userKeyID': instance.userKeyID,
      'userPrivateKey': instance.userPrivateKey,
      'userPassphrase': instance.userPassphrase,
    };

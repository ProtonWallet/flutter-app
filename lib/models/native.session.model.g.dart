// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native.session.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NativeSession _$NativeSessionFromJson(Map<String, dynamic> json) =>
    NativeSession(
      userId: json['userId'] as String,
      sessionId: json['sessionId'] as String,
      userName: json['userName'] as String,
      passphrase: json['passphrase'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );

Map<String, dynamic> _$NativeSessionToJson(NativeSession instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'sessionId': instance.sessionId,
      'userName': instance.userName,
      'passphrase': instance.passphrase,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };

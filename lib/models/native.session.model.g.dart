// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'native.session.model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NativeSession _$NativeSessionFromJson(Map<String, dynamic> json) =>
    NativeSession(
      UserId: json['UserId'] as String,
      SessionId: json['SessionId'] as String,
      Username: json['Username'] as String,
      Passphrase: json['Passphrase'] as String,
      AccessToken: json['AccessToken'] as String,
      RefreshToken: json['RefreshToken'] as String,
    );

Map<String, dynamic> _$NativeSessionToJson(NativeSession instance) =>
    <String, dynamic>{
      'UserId': instance.UserId,
      'SessionId': instance.SessionId,
      'Username': instance.Username,
      'Passphrase': instance.Passphrase,
      'AccessToken': instance.AccessToken,
      'RefreshToken': instance.RefreshToken,
    };

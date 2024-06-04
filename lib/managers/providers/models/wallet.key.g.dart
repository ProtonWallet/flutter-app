// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.key.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletKey _$WalletKeyFromJson(Map<String, dynamic> json) => WalletKey(
      json['walletId'] as String,
      json['userKeyId'] as String,
      json['walletKey'] as String,
      json['walletKeySignature'] as String,
    );

Map<String, dynamic> _$WalletKeyToJson(WalletKey instance) => <String, dynamic>{
      'walletId': instance.walletId,
      'userKeyId': instance.userKeyId,
      'walletKey': instance.walletKey,
      'walletKeySignature': instance.walletKeySignature,
    };

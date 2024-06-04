// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.passphrase.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletPassphrase _$WalletPassphraseFromJson(Map<String, dynamic> json) =>
    WalletPassphrase(
      walletID: json['walletID'] as String,
      passphrase: json['passphrase'] as String,
    );

Map<String, dynamic> _$WalletPassphraseToJson(WalletPassphrase instance) =>
    <String, dynamic>{
      'walletID': instance.walletID,
      'passphrase': instance.passphrase,
    };

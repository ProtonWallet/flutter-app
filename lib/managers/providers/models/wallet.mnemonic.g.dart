// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.mnemonic.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WalletMnemonic _$WalletMnemonicFromJson(Map<String, dynamic> json) =>
    WalletMnemonic(
      walletID: json['walletID'] as String,
      mnemonic: json['mnemonic'] as String,
    );

Map<String, dynamic> _$WalletMnemonicToJson(WalletMnemonic instance) =>
    <String, dynamic>{
      'walletID': instance.walletID,
      'mnemonic': instance.mnemonic,
    };

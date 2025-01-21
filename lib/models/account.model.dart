import 'dart:convert';
import 'dart:typed_data';

import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/rust/api/proton_wallet/crypto/wallet_key.dart';
import 'package:wallet/rust/api/proton_wallet/crypto/wallet_key_helper.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class AccountModel {
  int id;

  // unique account id from server
  String accountID;

  // wallet server id, 1 account : N
  String walletID;

  // 1 account : N,  join unique with wallet id
  String derivationPath;

  // encrypted label
  Uint8List label;

  // script type
  int scriptType;
  int createTime;
  int modifyTime;
  String fiatCurrency;
  int priority;
  int lastUsedIndex;
  int poolSize;
  int stopGap;

  String labelDecrypt = "Default Account";
  double balance = 0;

  AccountModel({
    required this.id,
    required this.accountID,
    required this.walletID,
    required this.derivationPath,
    required this.label,
    required this.poolSize,
    required this.priority,
    required this.scriptType,
    required this.createTime,
    required this.modifyTime,
    required this.fiatCurrency,
    required this.lastUsedIndex,
    required this.stopGap,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountID': accountID,
      'walletID': walletID,
      'derivationPath': derivationPath,
      'label': label,
      'poolSize': poolSize,
      'priority': priority,
      'scriptType': scriptType,
      'createTime': createTime,
      'modifyTime': modifyTime,
      'fiatCurrency': fiatCurrency,
      'lastUsedIndex': lastUsedIndex,
      'stopGap': stopGap,
    };
  }

  Future<void> decrypt(FrbUnlockedWalletKey unlockedWalletKey) async {
    // TODO(fix): fix me why 5 times
    for (int i = 0; i < 5; i++) {
      try {
        final String value = base64Encode(label);
        if (value != "") {
          labelDecrypt = FrbWalletKeyHelper.decrypt(
              base64SecureKey: unlockedWalletKey.toBase64(),
              encryptText: value);
        }
        break;
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 300));
        labelDecrypt = e.toString();
      }
    }
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    final AccountModel accountModel = AccountModel(
      id: map['id'],
      accountID: map['accountID'] ?? "",
      walletID: map['walletID'],
      derivationPath: map['derivationPath'],
      label: map['label'],
      poolSize: map['poolSize'],
      priority: map['priority'],
      scriptType: map['scriptType'],
      createTime: map['createTime'],
      modifyTime: map['modifyTime'],
      fiatCurrency: map['fiatCurrency'],
      lastUsedIndex: map['lastUsedIndex'],
      stopGap: map['stopGap'],
    );
    return accountModel;
  }

  // get fiat currency
  FiatCurrency getFiatCurrency() {
    return CommonHelper.getFiatCurrencyByName(
      fiatCurrency.toUpperCase(),
    );
  }
}

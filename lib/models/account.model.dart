import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'package:wallet/helper/walletkey_helper.dart';

class AccountModel {
  int? id;
  int walletID;
  String derivationPath;
  Uint8List label;
  int scriptType;
  int createTime;
  int modifyTime;

  String labelDecrypt = "Default Account";
  String serverAccountID;
  double balance = 0;
  String fiatCurrency;

  AccountModel({
    required this.id,
    required this.walletID,
    required this.derivationPath,
    required this.label,
    required this.scriptType,
    required this.createTime,
    required this.modifyTime,
    required this.serverAccountID,
    required this.fiatCurrency,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'walletID': walletID,
      'derivationPath': derivationPath,
      'label': label,
      'scriptType': scriptType,
      'createTime': createTime,
      'modifyTime': modifyTime,
      'serverAccountID': serverAccountID,
      'fiatCurrency': fiatCurrency,
    };
  }

  Future<void> decrypt(SecretKey secretKey) async {
    //TODO:: fix me why 5 times
    for (int i = 0; i < 5; i++) {
      try {
        String value = base64Encode(label);
        if (value != "") {
          labelDecrypt = await WalletKeyHelper.decrypt(secretKey, value);
        }
        break;
      } catch (e) {
        await Future.delayed(const Duration(milliseconds: 300));
        labelDecrypt = e.toString();
      }
    }
  }

  factory AccountModel.fromMap(Map<String, dynamic> map) {
    AccountModel accountModel = AccountModel(
      id: map['id'],
      walletID: map['walletID'],
      derivationPath: map['derivationPath'],
      label: map['label'],
      scriptType: map['scriptType'],
      createTime: map['createTime'],
      modifyTime: map['modifyTime'],
      serverAccountID: map['serverAccountID'] ?? "",
      fiatCurrency: map['fiatCurrency'],
    );
    return accountModel;
  }
}

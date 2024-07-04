import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:wallet/helper/walletkey_helper.dart';

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
  // TODO:: map to script type object
  int scriptType;
  int createTime;
  int modifyTime;
  String fiatCurrency;

  //TODO:: move to other place
  String labelDecrypt = "Default Account";
  //TODO:: move to other place
  double balance = 0;

  AccountModel({
    required this.id,
    required this.accountID,
    required this.walletID,
    required this.derivationPath,
    required this.label,
    required this.scriptType,
    required this.createTime,
    required this.modifyTime,
    required this.fiatCurrency,
  });

  Map<String, dynamic> toMap() {
    return {
      'accountID': accountID,
      'walletID': walletID,
      'derivationPath': derivationPath,
      'label': label,
      'scriptType': scriptType,
      'createTime': createTime,
      'modifyTime': modifyTime,
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
      accountID: map['accountID'] ?? "",
      walletID: map['walletID'],
      derivationPath: map['derivationPath'],
      label: map['label'],
      scriptType: map['scriptType'],
      createTime: map['createTime'],
      modifyTime: map['modifyTime'],
      fiatCurrency: map['fiatCurrency'],
    );
    return accountModel;
  }
}

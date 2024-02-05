import 'dart:convert';
import 'dart:typed_data';

import '../helper/wallet_manager.dart';

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

  AccountModel({
    required this.id,
    required this.walletID,
    required this.derivationPath,
    required this.label,
    required this.scriptType,
    required this.createTime,
    required this.modifyTime,
    required this.serverAccountID,
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
    };
  }

  Future<void> decrypt() async {
    String value = utf8.decode(label);
    if (value != "") {
      labelDecrypt = await WalletManager.decrypt(value);
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
    );
    accountModel.decrypt();
    return accountModel;
  }
}

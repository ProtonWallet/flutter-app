import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:wallet/helper/dbhelper.dart';

import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/wallet.model.dart';

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
    try {
      WalletModel walletModel = await DBHelper.walletDao!.findById(walletID);
      SecretKey? secretKey = await WalletManager.getWalletKey(walletModel.serverWalletID);
      String value = base64Encode(label);
      if (value != "" && secretKey != null) {
        labelDecrypt = await WalletKeyHelper.decrypt(secretKey, value);
      }
    } catch (e){
      labelDecrypt = e.toString();
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

import 'dart:typed_data';

class WalletModel {
  //TODO:: The constant name 'typeOnChain' isn't a lowerCamelCase identifier. fix this either change to lowercase or find other ways to save static const
  static const int typeOnChain = 1;
  static const int typeLightning = 2;
  static const int statusActive = 1;
  static const int statusDisabled = 2;
  static const int createByProton = 0;
  static const int importByUser = 1;
  static const int primary = 1;

  int? id;
  int userID;
  String name;
  Uint8List mnemonic;
  int passphrase;
  Uint8List publicKey;
  int imported;
  int priority;

  // int slot; server-side only
  int status;
  int type;
  int createTime;
  int modifyTime;

  // optional
  int accountCount = 0;
  double balance = 0;

  String serverWalletID;
  String? fingerprint;

  WalletModel(
      {required this.id,
      required this.userID,
      required this.name,
      required this.mnemonic,
      required this.passphrase,
      required this.publicKey,
      required this.imported,
      required this.priority,
      required this.status,
      required this.type,
      required this.fingerprint,
      required this.createTime,
      required this.modifyTime,
      required this.serverWalletID});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userID': userID,
      'name': name,
      'mnemonic': mnemonic,
      'passphrase': passphrase,
      'publicKey': publicKey,
      'imported': imported,
      'priority': priority,
      'status': status,
      'type': type,
      'fingerprint': fingerprint,
      'createTime': createTime,
      'modifyTime': modifyTime,
      'serverWalletID': serverWalletID,
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map) {
    return WalletModel(
      id: map['id'],
      userID: map['userID'],
      name: map['name'],
      mnemonic: map['mnemonic'],
      passphrase: map['passphrase'],
      publicKey: map['publicKey'],
      imported: map['imported'],
      priority: map['priority'],
      status: map['status'],
      type: map['type'],
      fingerprint: map['fingerprint'],
      createTime: map['createTime'],
      modifyTime: map['modifyTime'],
      serverWalletID: map['serverWalletID'] ?? "",
    );
  }
}

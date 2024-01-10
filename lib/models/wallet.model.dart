import 'dart:typed_data';

class WalletModel {
  //TODO:: The constant name 'TYPE_ON_CHAIN' isn't a lowerCamelCase identifier. fix this either change to lowercase or find other ways to save static const
  static const int TYPE_ON_CHAIN = 1;
  static const int TYPE_LIGHTNING = 2;
  static const int STATUS_ACTIVE = 1;
  static const int STATUS_DISABLED = 2;
  static const int CREATE_BY_PROTON = 0;
  static const int IMPORTED_BY_USER = 1;
  static const int PRIMARY = 1;

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
  String localDBName;

  // optional
  int accountCount = 0;
  double balance = 0;

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
      required this.createTime,
      required this.modifyTime,
      required this.localDBName});

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
      'createTime': createTime,
      'modifyTime': modifyTime,
      'localDBName': localDBName,
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
      createTime: map['createTime'],
      modifyTime: map['modifyTime'],
      localDBName: map['localDBName'],
    );
  }
}

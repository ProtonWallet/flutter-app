import 'dart:typed_data';

class TransactionModel {
  int? id;
  int walletID;
  Uint8List label;
  Uint8List externalTransactionID;
  int createTime;
  int modifyTime;

  TransactionModel({
    required this.id,
    required this.walletID,
    required this.label,
    required this.externalTransactionID,
    required this.createTime,
    required this.modifyTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'walletID': walletID,
      'label': label,
      'externalTransactionID': externalTransactionID,
      'createTime': createTime,
      'modifyTime': modifyTime,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      walletID: map['walletID'],
      label: map['label'],
      externalTransactionID: map['externalTransactionID'],
      createTime: map['createTime'],
      modifyTime: map['modifyTime'],
    );
  }
}

import 'dart:typed_data';

class TransactionInfoModel {
  int? id;
  Uint8List externalTransactionID;
  int amountInSATS;
  int feeInSATS;
  int isSend;
  int transactionTime;
  int feeMode;

  TransactionInfoModel({
    required this.id,
    required this.externalTransactionID,
    required this.amountInSATS,
    required this.feeInSATS,
    required this.isSend,
    required this.transactionTime,
    required this.feeMode,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'externalTransactionID': externalTransactionID,
      'amountInSATS': amountInSATS,
      'feeInSATS': feeInSATS,
      'isSend': isSend,
      'transactionTime': transactionTime,
      'feeMode': feeMode,
    };
  }

  factory TransactionInfoModel.fromMap(Map<String, dynamic> map) {
    return TransactionInfoModel(
      id: map['id'],
      externalTransactionID: map['externalTransactionID'],
      amountInSATS: map['amountInSATS'],
      feeInSATS: map['feeInSATS'],
      isSend: map['isSend'],
      transactionTime: map['transactionTime'],
      feeMode: map['feeMode'],
    );
  }
}

import 'dart:typed_data';

class TransactionInfoModel {
  int? id;
  Uint8List externalTransactionID;
  int amountInSATS;
  int feeInSATS;
  int isSend;
  int transactionTime;
  int feeMode;
  String serverWalletID;
  String serverAccountID;
  String toEmail;
  String toBitcoinAddress;

  TransactionInfoModel({
    required this.id,
    required this.externalTransactionID,
    required this.amountInSATS,
    required this.feeInSATS,
    required this.isSend,
    required this.transactionTime,
    required this.feeMode,
    required this.serverWalletID,
    required this.serverAccountID,
    required this.toEmail,
    required this.toBitcoinAddress,
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
      'serverWalletID': serverWalletID,
      'serverAccountID': serverAccountID,
      'toEmail': toEmail,
      'toBitcoinAddress': toBitcoinAddress,
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
      serverWalletID: map['serverWalletID'],
      serverAccountID: map['serverAccountID'],
      toEmail: map['toEmail'],
      toBitcoinAddress: map['toBitcoinAddress'],
    );
  }
}

class BitcoinAddressModel {
  int? id;
  int walletID;
  int accountID;
  String bitcoinAddress;
  int bitcoinAddressIndex;
  int inEmailIntegrationPool;
  int used;

  BitcoinAddressModel({
    required this.id,
    required this.walletID,
    required this.accountID,
    required this.bitcoinAddress,
    required this.bitcoinAddressIndex,
    required this.inEmailIntegrationPool,
    required this.used,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'walletID': walletID,
      'accountID': accountID,
      'bitcoinAddress': bitcoinAddress,
      'bitcoinAddressIndex': bitcoinAddressIndex,
      'inEmailIntegrationPool': inEmailIntegrationPool,
      'used': used,
    };
  }

  factory BitcoinAddressModel.fromMap(Map<String, dynamic> map) {
    return BitcoinAddressModel(
      id: map['id'],
      walletID: map['walletID'],
      accountID: map['accountID'],
      bitcoinAddress: map['bitcoinAddress'],
      bitcoinAddressIndex: map['bitcoinAddressIndex'],
      inEmailIntegrationPool: map['inEmailIntegrationPool'],
      used: map['used'],
    );
  }
}

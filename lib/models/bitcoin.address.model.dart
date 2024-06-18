class BitcoinAddressModel {
  int? id;
  int walletID;
  int accountID;
  String bitcoinAddress;
  int bitcoinAddressIndex;
  int inEmailIntegrationPool;
  int used;
  String serverWalletID;
  String serverAccountID;

  BitcoinAddressModel({
    required this.id,
    required this.walletID,
    required this.accountID,
    required this.serverWalletID,
    required this.serverAccountID,
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
      'serverWalletID': serverWalletID,
      'serverAccountID': serverAccountID,
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
      serverWalletID: map['serverWalletID'],
      serverAccountID: map['serverAccountID'],
      bitcoinAddress: map['bitcoinAddress'],
      bitcoinAddressIndex: map['bitcoinAddressIndex'],
      inEmailIntegrationPool: map['inEmailIntegrationPool'],
      used: map['used'],
    );
  }
}

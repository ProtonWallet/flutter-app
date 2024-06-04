class ExchangeRateModel {
  int? id;
  String serverID;
  String bitcoinUnit;
  String fiatCurrency;
  String sign;
  String exchangeRateTime;
  int exchangeRate;
  int cents;

  ExchangeRateModel({
    required this.id,
    required this.serverID,
    required this.bitcoinUnit,
    required this.fiatCurrency,
    required this.sign,
    required this.exchangeRateTime,
    required this.exchangeRate,
    required this.cents,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serverID': serverID,
      'bitcoinUnit': bitcoinUnit,
      'fiatCurrency': fiatCurrency,
      'sign': sign,
      'exchangeRateTime': exchangeRateTime,
      'exchangeRate': exchangeRate,
      'cents': cents,
    };
  }

  factory ExchangeRateModel.fromMap(Map<String, dynamic> map) {
    return ExchangeRateModel(
      id: map['id'],
      serverID: map['serverID'],
      bitcoinUnit: map['bitcoinUnit'],
      fiatCurrency: map['fiatCurrency'],
      sign: map['sign'],
      exchangeRateTime: map['exchangeRateTime'],
      exchangeRate: map['exchangeRate'],
      cents: map['cents'],
    );
  }
}

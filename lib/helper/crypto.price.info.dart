class CryptoPriceInfo {
  final String symbol;
  final double price;
  final double priceChange24h;

  CryptoPriceInfo({
    this.symbol = "BTCUSDT",
    this.price = 0.0,
    this.priceChange24h = 0.0,
  });
}

class BitcoinTransactionFee {
  final double block1Fee;
  final double block2Fee;
  final double block3Fee;
  final double block5Fee;
  final double block10Fee;
  final double block20Fee;

  BitcoinTransactionFee({
    required this.block1Fee,
    required this.block2Fee,
    required this.block3Fee,
    required this.block5Fee,
    required this.block10Fee,
    required this.block20Fee,
  });
}

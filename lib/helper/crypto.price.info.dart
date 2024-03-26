class CryptoPriceInfo {
  final String symbol;
  final double price;
  final double priceChange24h;

  CryptoPriceInfo({
    required this.symbol,
    required this.price,
    required this.priceChange24h,
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

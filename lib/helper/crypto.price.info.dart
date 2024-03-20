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
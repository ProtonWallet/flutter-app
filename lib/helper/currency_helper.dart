class CurrencyHelper {
  static double btcValue = 43000;

  static double btc2usdt(double balance) {
    return balance * btcValue;
  }
  static double sat2usdt(double balance) {
    return balance * btcValue * 0.00000001;
  }
}

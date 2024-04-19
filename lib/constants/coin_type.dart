class CoinType {
  String name;
  int type;

  CoinType({required this.name, required this.type});

  static final CoinType bitcoin = CoinType(name: "Bitcoin", type: 0);
  static final CoinType bitcoinTestnet =CoinType(name: "Bitcoin Testnet", type: 1);

}

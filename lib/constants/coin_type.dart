import 'package:wallet/rust/bdk/types.dart';

class CoinType {
  String name;
  int type;
  Network network;

  CoinType({required this.name, required this.type, required this.network});
}

final CoinType bitcoin =
    CoinType(name: "Bitcoin", type: 0, network: Network.bitcoin);
final CoinType bitcoinTestnet =
    CoinType(name: "Bitcoin Testnet", type: 1, network: Network.testnet);

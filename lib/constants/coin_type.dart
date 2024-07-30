import 'package:wallet/rust/common/network.dart';

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
final CoinType bitcoinRegtest =
    CoinType(name: "Bitcoin Regtest", type: 1, network: Network.regtest);

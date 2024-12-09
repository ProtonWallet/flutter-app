import 'package:wallet/rust/common/network.dart';

class CoinType {
  String name;
  int type;
  Network network;

  CoinType({required this.name, required this.type, required this.network});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CoinType &&
        other.name == name &&
        other.type == type &&
        other.network == network;
  }

  @override
  int get hashCode => Object.hash(name, type, network);

  @override
  String toString() => 'CoinType(name: $name, type: $type, network: $network)';
}

final CoinType bitcoin =
    CoinType(name: "Bitcoin", type: 0, network: Network.bitcoin);
final CoinType bitcoinTestnet =
    CoinType(name: "Bitcoin Testnet", type: 1, network: Network.testnet);
final CoinType bitcoinRegtest =
    CoinType(name: "Bitcoin Regtest", type: 1, network: Network.regtest);

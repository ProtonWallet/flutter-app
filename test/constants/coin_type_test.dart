import 'package:flutter_test/flutter_test.dart';
import 'package:wallet/constants/coin_type.dart';
import 'package:wallet/rust/common/network.dart';

import '../helper.dart';

void main() {
  testUnit('Equality of identical CoinType instances', () {
    final coin1 = CoinType(name: "Bitcoin", type: 0, network: Network.bitcoin);
    final coin2 = CoinType(name: "Bitcoin", type: 0, network: Network.bitcoin);

    // Test equality
    expect(coin1, equals(coin2));

    // Test hashCode equality
    expect(coin1.hashCode, equals(coin2.hashCode));
  });

  testUnit('Inequality of CoinType instances with different names', () {
    final coin1 = CoinType(name: "Bitcoin", type: 0, network: Network.bitcoin);
    final coin2 = CoinType(name: "Litecoin", type: 0, network: Network.bitcoin);

    // Test inequality
    expect(coin1, isNot(equals(coin2)));
  });

  testUnit('Inequality of CoinType instances with different types', () {
    final coin1 = CoinType(name: "Bitcoin", type: 0, network: Network.bitcoin);
    final coin2 = CoinType(name: "Bitcoin", type: 1, network: Network.bitcoin);

    // Test inequality
    expect(coin1, isNot(equals(coin2)));
  });

  testUnit('Inequality of CoinType instances with different networks', () {
    final coin1 = CoinType(name: "Bitcoin", type: 0, network: Network.bitcoin);
    final coin2 = CoinType(name: "Bitcoin", type: 0, network: Network.testnet);

    // Test inequality
    expect(coin1, isNot(equals(coin2)));
  });

  testUnit('Predefined CoinType instances equality', () {
    final expectedBitcoin =
        CoinType(name: "Bitcoin", type: 0, network: Network.bitcoin);
    final expectedTestnet =
        CoinType(name: "Bitcoin Testnet", type: 1, network: Network.testnet);
    final expectedRegtest =
        CoinType(name: "Bitcoin Regtest", type: 1, network: Network.regtest);

    // Test predefined instances
    expect(bitcoin, equals(expectedBitcoin));
    expect(bitcoinTestnet, equals(expectedTestnet));
    expect(bitcoinRegtest, equals(expectedRegtest));
  });

  testUnit('CoinType toString output', () {
    final coin = CoinType(name: "Bitcoin", type: 0, network: Network.bitcoin);

    // Test toString output
    expect(
      coin.toString(),
      'CoinType(name: Bitcoin, type: 0, network: Network.bitcoin)',
    );
  });
}

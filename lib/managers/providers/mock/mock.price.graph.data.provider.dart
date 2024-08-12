import 'dart:async';

import 'package:wallet/managers/providers/price.graph.data.provider.dart';
import 'package:wallet/rust/proton_api/price_graph.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class MockPriceGraphDataProvider extends PriceGraphDataProvider {
  MockPriceGraphDataProvider() : super(null);

  @override
  Future<PriceGraph?> getPriceGraph({
    required FiatCurrency fiatCurrency,
    required Timeframe timeFrame,
  }) async {
    if (timeFrame == Timeframe.oneDay) {
      return PriceGraph(
        fiatCurrency: fiatCurrency,
        bitcoinUnit: BitcoinUnit.btc,
        graphData: [
          DataPoint(
              exchangeRate: BigInt.from(600000),
              cents: 10,
              timestamp: BigInt.from(1)),
          DataPoint(
              exchangeRate: BigInt.from(610000),
              cents: 10,
              timestamp: BigInt.from(2)),
          DataPoint(
              exchangeRate: BigInt.from(620000),
              cents: 10,
              timestamp: BigInt.from(3)),
          DataPoint(
              exchangeRate: BigInt.from(630000),
              cents: 10,
              timestamp: BigInt.from(4)),
          DataPoint(
              exchangeRate: BigInt.from(640000),
              cents: 10,
              timestamp: BigInt.from(5)),
          DataPoint(
              exchangeRate: BigInt.from(650000),
              cents: 10,
              timestamp: BigInt.from(6)),
          DataPoint(
              exchangeRate: BigInt.from(660000),
              cents: 10,
              timestamp: BigInt.from(7)),
          DataPoint(
              exchangeRate: BigInt.from(670000),
              cents: 10,
              timestamp: BigInt.from(8)),
          DataPoint(
              exchangeRate: BigInt.from(660000),
              cents: 10,
              timestamp: BigInt.from(9)),
          DataPoint(
              exchangeRate: BigInt.from(650000),
              cents: 10,
              timestamp: BigInt.from(10)),
        ],
      );
    } else if (timeFrame == Timeframe.oneWeek) {
      return PriceGraph(
        fiatCurrency: fiatCurrency,
        bitcoinUnit: BitcoinUnit.btc,
        graphData: [
          DataPoint(
              exchangeRate: BigInt.from(1700000),
              cents: 10,
              timestamp: BigInt.from(1)),
          DataPoint(
              exchangeRate: BigInt.from(1610000),
              cents: 10,
              timestamp: BigInt.from(2)),
          DataPoint(
              exchangeRate: BigInt.from(1620000),
              cents: 10,
              timestamp: BigInt.from(3)),
          DataPoint(
              exchangeRate: BigInt.from(1630000),
              cents: 10,
              timestamp: BigInt.from(4)),
          DataPoint(
              exchangeRate: BigInt.from(1640000),
              cents: 10,
              timestamp: BigInt.from(5)),
          DataPoint(
              exchangeRate: BigInt.from(1650000),
              cents: 10,
              timestamp: BigInt.from(6)),
          DataPoint(
              exchangeRate: BigInt.from(1660000),
              cents: 10,
              timestamp: BigInt.from(7)),
          DataPoint(
              exchangeRate: BigInt.from(1670000),
              cents: 10,
              timestamp: BigInt.from(8)),
          DataPoint(
              exchangeRate: BigInt.from(1660000),
              cents: 10,
              timestamp: BigInt.from(9)),
          DataPoint(
              exchangeRate: BigInt.from(1650000),
              cents: 10,
              timestamp: BigInt.from(10)),
        ],
      );
    }
    return PriceGraph(
      fiatCurrency: fiatCurrency,
      bitcoinUnit: BitcoinUnit.btc,
      graphData: [
        DataPoint(
            exchangeRate: BigInt.from(2600000),
            cents: 10,
            timestamp: BigInt.from(1)),
        DataPoint(
            exchangeRate: BigInt.from(2610000),
            cents: 10,
            timestamp: BigInt.from(2)),
        DataPoint(
            exchangeRate: BigInt.from(2620000),
            cents: 10,
            timestamp: BigInt.from(3)),
        DataPoint(
            exchangeRate: BigInt.from(2630000),
            cents: 10,
            timestamp: BigInt.from(4)),
        DataPoint(
            exchangeRate: BigInt.from(2640000),
            cents: 10,
            timestamp: BigInt.from(5)),
        DataPoint(
            exchangeRate: BigInt.from(2650000),
            cents: 10,
            timestamp: BigInt.from(6)),
        DataPoint(
            exchangeRate: BigInt.from(2660000),
            cents: 10,
            timestamp: BigInt.from(7)),
        DataPoint(
            exchangeRate: BigInt.from(2670000),
            cents: 10,
            timestamp: BigInt.from(8)),
        DataPoint(
            exchangeRate: BigInt.from(2660000),
            cents: 10,
            timestamp: BigInt.from(9)),
        DataPoint(
            exchangeRate: BigInt.from(2650000),
            cents: 10,
            timestamp: BigInt.from(10)),
      ],
    );
  }
}

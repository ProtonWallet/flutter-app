import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/managers/providers/mock/mock.price.graph.data.provider.dart';
import 'package:wallet/rust/proton_api/price_graph.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/components/bitcoin.price.chart.dart';

import '../../mocks/proton.exchange.rate.mocks.dart';
import '../helper/comparator.config.dart';
import '../helper/test.wrapper.dart';

void main() {
  const testPath = 'bitcoin.price.chart';
  provideDummy<BigInt>(BigInt.zero);

  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('bitcoin price chart with default time frame', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0001);

    final exchangeRate = MockProtonExchangeRate();
    when(exchangeRate.fiatCurrency).thenReturn(FiatCurrency.usd);
    when(exchangeRate.bitcoinUnit).thenReturn(BitcoinUnit.sats);
    when(exchangeRate.exchangeRate).thenReturn(BigInt.from(101994.70));
    when(exchangeRate.cents).thenReturn(BigInt.from(100));

    final priceGraphDataProvider = MockPriceGraphDataProvider();

    final widget = BitcoinPriceChart(
      exchangeRate: exchangeRate,
      priceGraphDataProvider: priceGraphDataProvider,
    );

    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/1d.grid",
    );
  });

  testSnapshot('bitcoin price chart with 1 week time frame', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0001);

    final exchangeRate = MockProtonExchangeRate();
    when(exchangeRate.fiatCurrency).thenReturn(FiatCurrency.usd);
    when(exchangeRate.bitcoinUnit).thenReturn(BitcoinUnit.sats);
    when(exchangeRate.exchangeRate).thenReturn(BigInt.from(101994.70));
    when(exchangeRate.cents).thenReturn(BigInt.from(100));

    final priceGraphDataProvider = MockPriceGraphDataProvider();

    final widget = BitcoinPriceChart(
      exchangeRate: exchangeRate,
      priceGraphDataProvider: priceGraphDataProvider,
      defaultTimeFrame: Timeframe.oneWeek,
    );

    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/1w.grid",
    );
  });

  testSnapshot('bitcoin price chart with 1 month time frame', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0001);

    final exchangeRate = MockProtonExchangeRate();
    when(exchangeRate.fiatCurrency).thenReturn(FiatCurrency.usd);
    when(exchangeRate.bitcoinUnit).thenReturn(BitcoinUnit.sats);
    when(exchangeRate.exchangeRate).thenReturn(BigInt.from(101994.70));
    when(exchangeRate.cents).thenReturn(BigInt.from(100));

    final priceGraphDataProvider = MockPriceGraphDataProvider();

    final widget = BitcoinPriceChart(
      exchangeRate: exchangeRate,
      priceGraphDataProvider: priceGraphDataProvider,
      defaultTimeFrame: Timeframe.oneMonth,
    );

    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/1m.grid",
    );
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/managers/providers/mock/mock.price.graph.data.provider.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/rust/proton_api/price_graph.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/components/bitcoin.price.chart.dart';

import '../../mocks/proton.exchange.rate.mocks.dart';
import '../../mocks/theme.provider.mocks.dart';
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

    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateLightTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(false);

    final exchangeRate = MockProtonExchangeRate();
    when(exchangeRate.fiatCurrency).thenReturn(FiatCurrency.usd);
    when(exchangeRate.bitcoinUnit).thenReturn(BitcoinUnit.sats);
    when(exchangeRate.exchangeRate).thenReturn(BigInt.from(101994.70));
    when(exchangeRate.cents).thenReturn(BigInt.from(100));

    final priceGraphDataProvider = MockPriceGraphDataProvider();

    final widget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: BitcoinPriceChart(
        exchangeRate: exchangeRate,
        priceGraphDataProvider: priceGraphDataProvider,
      ),
    );

    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/$testPath.1d",
    );
  });

  testSnapshot('bitcoin price chart with default time frame dark',
      (tester) async {
    setGoldenFileComparatorWithThreshold(0.0001);

    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateDarkTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(true);

    final exchangeRate = MockProtonExchangeRate();
    when(exchangeRate.fiatCurrency).thenReturn(FiatCurrency.usd);
    when(exchangeRate.bitcoinUnit).thenReturn(BitcoinUnit.sats);
    when(exchangeRate.exchangeRate).thenReturn(BigInt.from(101994.70));
    when(exchangeRate.cents).thenReturn(BigInt.from(100));

    final priceGraphDataProvider = MockPriceGraphDataProvider();

    final widget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: BitcoinPriceChart(
        exchangeRate: exchangeRate,
        priceGraphDataProvider: priceGraphDataProvider,
      ),
    );

    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/$testPath.1d.dark",
    );
  });

  testSnapshot('bitcoin price chart with 1 week time frame', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0001);

    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateLightTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(false);

    final exchangeRate = MockProtonExchangeRate();
    when(exchangeRate.fiatCurrency).thenReturn(FiatCurrency.usd);
    when(exchangeRate.bitcoinUnit).thenReturn(BitcoinUnit.sats);
    when(exchangeRate.exchangeRate).thenReturn(BigInt.from(101994.70));
    when(exchangeRate.cents).thenReturn(BigInt.from(100));

    final priceGraphDataProvider = MockPriceGraphDataProvider();

    final widget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: BitcoinPriceChart(
        exchangeRate: exchangeRate,
        priceGraphDataProvider: priceGraphDataProvider,
        defaultTimeFrame: Timeframe.oneWeek,
      ),
    );

    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/$testPath.1w",
    );
  });

  testSnapshot('bitcoin price chart with 1 month time frame', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0001);

    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateLightTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(false);

    final exchangeRate = MockProtonExchangeRate();
    when(exchangeRate.fiatCurrency).thenReturn(FiatCurrency.usd);
    when(exchangeRate.bitcoinUnit).thenReturn(BitcoinUnit.sats);
    when(exchangeRate.exchangeRate).thenReturn(BigInt.from(101994.70));
    when(exchangeRate.cents).thenReturn(BigInt.from(100));

    final priceGraphDataProvider = MockPriceGraphDataProvider();

    final widget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: BitcoinPriceChart(
        exchangeRate: exchangeRate,
        priceGraphDataProvider: priceGraphDataProvider,
        defaultTimeFrame: Timeframe.oneMonth,
      ),
    );

    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/$testPath.1m",
    );
  });
}

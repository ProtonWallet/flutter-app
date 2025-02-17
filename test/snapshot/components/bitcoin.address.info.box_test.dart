import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/components/bitcoin.address.info.box.dart';

import '../../mocks/frb.objects.mocks.dart';
import '../../mocks/proton.exchange.rate.mocks.dart';
import '../../mocks/theme.provider.mocks.dart';
import '../helper/comparator.config.dart';
import '../helper/test.wrapper.dart';

void main() {
  const testPath = 'bitcoin.address.info';
  // Provide a dummy value for BigInt
  provideDummy<BigInt>(BigInt.zero);

  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('Bitcoin address info box tests', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0006);

    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateLightTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(false);

    ///
    final amount = MockFrbAmount();
    when(amount.toSat()).thenReturn(BigInt.from(1000000));

    ///
    final balancce = MockFrbBalance();
    when(balancce.total()).thenReturn(amount);

    ///
    final address = MockFrbAddressDetails();
    when(address.address).thenReturn("alsdjfklsadjflksjd");
    when(address.index).thenReturn(100);
    when(address.transactions).thenReturn([]);
    when(address.balance).thenReturn(balancce);
    when(address.isTransEmpty).thenReturn(true);

    ///
    final exchangeRate = MockProtonExchangeRate();
    when(exchangeRate.fiatCurrency).thenReturn(FiatCurrency.usd);
    when(exchangeRate.bitcoinUnit).thenReturn(BitcoinUnit.sats);
    when(exchangeRate.exchangeRate).thenReturn(BigInt.from(101994.70));
    final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
      ..addScenario(
        'Sample bitcoin address info: inpool true',
        BitcoinAddressInfoBox(
          bitcoinAddressDetail: address,
          exchangeRate: exchangeRate,
          showTransactionDetailCallback: (frbTransactionDetails) => {},
          showAddressQRcodeCallback: (address) => {},
          inPool: true,
        ),
      );
    builder.addScenario(
      'Sample bitcoin address info: inpool false',
      BitcoinAddressInfoBox(
        bitcoinAddressDetail: address,
        exchangeRate: exchangeRate,
        showTransactionDetailCallback: (frbTransactionDetails) => {},
        showAddressQRcodeCallback: (address) => {},
        inPool: false,
      ),
    );

    ///
    final addressTwo = MockFrbAddressDetails();
    when(addressTwo.address).thenReturn("alsdjfklsadjflksjd");
    when(addressTwo.index).thenReturn(102);
    when(addressTwo.transactions).thenReturn([]);
    when(addressTwo.balance).thenReturn(balancce);
    when(addressTwo.isTransEmpty).thenReturn(false);
    builder.addScenario(
      'Sample bitcoin address info: inpool false',
      BitcoinAddressInfoBox(
        bitcoinAddressDetail: addressTwo,
        exchangeRate: exchangeRate,
        showTransactionDetailCallback: (frbTransactionDetails) => {},
        showAddressQRcodeCallback: (address) => {},
        inPool: false,
      ),
    );

    ///
    final transaction1 = MockFrbTransactionDetails();
    when(transaction1.txid).thenReturn("this is a txid");
    final transaction2 = MockFrbTransactionDetails();
    when(transaction2.txid).thenReturn("this is a txid");
    final address3 = MockFrbAddressDetails();
    when(address3.address).thenReturn("alsdjfklsadjflksjd");
    when(address3.index).thenReturn(102);
    when(address3.transactions).thenReturn([transaction1, transaction2]);
    when(address3.balance).thenReturn(balancce);
    when(address3.isTransEmpty).thenReturn(false);
    builder.addScenario(
      'Sample bitcoin address info: inpool false',
      BitcoinAddressInfoBox(
        bitcoinAddressDetail: address3,
        exchangeRate: exchangeRate,
        showTransactionDetailCallback: (frbTransactionDetails) => {},
        showAddressQRcodeCallback: (address) => {},
        inPool: false,
        showTransactions: true,
      ),
    );

    final widget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: builder.build(),
    );

    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/bitcoin.address.info.grid",
    );
  });
}

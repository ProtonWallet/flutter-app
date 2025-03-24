import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/components/btc.address/bitcoin.address.info.box.dart';

import '../../mocks/frb.objects.mocks.dart';
import '../../mocks/proton.exchange.rate.mocks.dart';
import '../helper/comparator.config.dart';
import '../helper/test.wrapper.dart';
import '../helper/theme.dart';
import '../helper/widget.ext.dart';

void main() {
  const testPath = 'bitcoin.address.info';

  // Provide a dummy value for BigInt
  provideDummy<BigInt>(BigInt.zero);

  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('Bitcoin address info box tests light mode', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0006);

    final widget = buildTestContent().withTheme(lightTheme());
    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/$testPath.light",
    );
  });

  testSnapshot('Bitcoin address info box tests dark mode', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0006);

    final widget = buildTestContent().withTheme(darkTheme());
    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/$testPath.dark",
    );
  });
}

Widget buildTestContent() {
  ///
  final amount = MockFrbAmount();
  when(amount.toSat()).thenReturn(BigInt.from(1000000));

  ///
  final balancce = MockFrbBalance();
  when(balancce.total()).thenReturn(amount);

  ///
  final address = MockFrbAddressDetails();
  when(address.address)
      .thenReturn("bc1q9v9gk3df8c6unrhw9pzdw7fclu45n9rwwxx7z5");
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
      Column(
        children: [
          BitcoinAddressInfoBox(
            bitcoinAddressDetail: address,
            exchangeRate: exchangeRate,
            showTransactionDetailCallback: (frbTransactionDetails) => {},
            showAddressQRcodeCallback: (address) => {},
            inPool: true,
            onSigningCallback: (String address) {},
          ),
        ],
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
      onSigningCallback: (String address) {},
    ),
  );

  ///
  final addressTwo = MockFrbAddressDetails();
  when(addressTwo.address)
      .thenReturn("bc1q9v9gk3df8c6unrhw9pzdw7fclu45n9rwwxx7z5");
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
      onSigningCallback: (String address) {},
    ),
  );

  return builder.build();
}

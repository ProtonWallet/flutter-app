import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:wallet/scenes/components/home/btc.actions.view.dart';

import '../helper/test.wrapper.dart';

void main() {
  const testPath = 'btc.actions.view';
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('btc actions view test', (tester) async {
    final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
      ..addScenario(
        'All disabled',
        BtcTitleActionsView(
          initialized: false,
        ),
      )
      ..addScenario(
        'All enabled',
        BtcTitleActionsView(
          initialized: true,
        ),
      )
      ..addScenario(
        'All enabled except Buy',
        BtcTitleActionsView(
          initialized: true,
          disableBuy: true,
        ),
      );
    await testAcrossAllDevices(
      tester,
      builder.build,
      "$testPath/btc.actions.grid",
    );
  });
}

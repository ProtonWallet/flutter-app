import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/scenes/components/home/btc.actions.view.dart';

import '../../mocks/theme.provider.mocks.dart';
import '../helper/test.wrapper.dart';

void main() {
  const testPath = 'btc.actions.view';
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('btc actions view test', (tester) async {
    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateLightTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(false);

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

    final widget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: builder.build(),
    );
    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/btc.actions.grid",
    );
  });
}

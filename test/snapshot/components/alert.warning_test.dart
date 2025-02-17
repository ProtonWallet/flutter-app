import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/scenes/components/alert.warning.dart';

import '../../mocks/theme.provider.mocks.dart';
import '../helper/test.wrapper.dart';

void main() {
  const testPath = 'alert.warning';
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('Alert warning tests', (tester) async {
    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateLightTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(false);
    final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
      ..addScenario(
          'Sample passphrase alert warning 350w',
          AlertWarning(
            content:
                "Store your passphrase at a safe location. Without the passphrase, even Proton cannot recover your funds.",
            width: 350,
          ))
      ..addScenario(
          'Sample passphrase alert warning 300w',
          AlertWarning(
            content:
                "Store your passphrase at a safe location. Without the passphrase, even Proton cannot recover your funds.",
            width: 300,
          ))
      ..addScenario(
          'Sample passphrase alert warning 200w',
          AlertWarning(
            content:
                "Store your passphrase at a safe location. Without the passphrase, even Proton cannot recover your funds.",
            width: 200,
          ));

    final widget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: builder.build(),
    );

    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/alert.warning.grid",
    );
  });
}

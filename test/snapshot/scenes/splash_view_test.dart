import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/scenes/app/app.view.dart';

import '../../mocks/theme.provider.mocks.dart';
import '../helper/comparator.config.dart';
import '../helper/test.wrapper.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('splash view tests', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0001);

    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateLightTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(false);

    final widget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: const SplashView(),
    );

    await testAcrossAllDevices(tester, () => widget, 'app/splash_view');
  });
}

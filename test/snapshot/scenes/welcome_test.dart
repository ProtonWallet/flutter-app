import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/welcome/welcome.view.dart';

import '../../mocks/theme.provider.mocks.dart';
import '../../mocks/welcome.mocks.dart';
import '../helper/comparator.config.dart';
import '../helper/test.wrapper.dart';

// works with --- command: make build-runner
void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('Welcome mobile', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0006);

    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateLightTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(false);

    final viewModel = MockWelcomeViewModel();
    when(viewModel.keepAlive).thenAnswer((_) => true);
    when(viewModel.isLoginToHomepage).thenAnswer((_) => false);
    when(viewModel.screenSizeState).thenAnswer((_) => false);
    when(viewModel.coordinator).thenAnswer((_) => MockWelcomeCoordinator());
    when(viewModel.datasourceChanged).thenAnswer(
      (_) => StreamController<MockWelcomeViewModel>.broadcast().stream,
    );
    when(viewModel.currentSize).thenAnswer((_) => ViewSize.mobile);

    final widget = WelcomeView(
      viewModel,
    );

    final testview = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: widget,
    );

    await testAcrossAllDevices(tester, () => testview, 'welcome/welcome_view');
  });

  testSnapshot('Welcome mobile dark', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0006);

    final mockThemeProvider = MockThemeProvider();
    when(mockThemeProvider.isDarkMode()).thenReturn(true);
    ProtonColors.updateDarkTheme();

    final viewModel = MockWelcomeViewModel();
    when(viewModel.keepAlive).thenAnswer((_) => true);
    when(viewModel.isLoginToHomepage).thenAnswer((_) => false);
    when(viewModel.screenSizeState).thenAnswer((_) => false);
    when(viewModel.coordinator).thenAnswer((_) => MockWelcomeCoordinator());
    when(viewModel.datasourceChanged).thenAnswer(
      (_) => StreamController<MockWelcomeViewModel>.broadcast().stream,
    );
    when(viewModel.currentSize).thenAnswer((_) => ViewSize.mobile);

    final widget = WelcomeView(
      viewModel,
    );

    final testview = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: widget,
    );

    await testAcrossAllDevices(tester, () => testview, 'welcome/dark_view');
  });
}

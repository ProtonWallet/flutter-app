import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/two.factor.auth.disable/two.factor.auth.disable.coordinator.dart';
import 'package:wallet/scenes/two.factor.auth.disable/two.factor.auth.disable.view.dart';
import 'package:wallet/scenes/two.factor.auth.disable/two.factor.auth.disable.viewmodel.dart';

import '../../mocks/theme.provider.mocks.dart';
import '../helper/comparator.config.dart';
import '../helper/test.wrapper.dart';
import 'signin_test.mocks.dart';
import 'twofa.disable_test.mocks.dart';

@GenerateMocks([
  TwoFactorAuthDisableViewModel,
  TwoFactorAuthDisableCoordinator,
])
void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('twofa disable mobile', (tester) async {
    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateLightTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(false);

    final viewModel = MockTwoFactorAuthDisableViewModel();
    when(viewModel.keepAlive).thenAnswer((_) => true);
    when(viewModel.screenSizeState).thenAnswer((_) => false);
    when(viewModel.coordinator)
        .thenAnswer((_) => MockTwoFactorAuthDisableCoordinator());
    when(viewModel.datasourceChanged).thenAnswer(
      (_) => StreamController<MockSigninViewModel>.broadcast().stream,
    );
    when(viewModel.currentSize).thenAnswer((_) => ViewSize.mobile);
    when(viewModel.digitControllers)
        .thenReturn(List.generate(6, (index) => TextEditingController()));
    when(viewModel.error).thenReturn("");
    when(viewModel.passwordController).thenReturn(TextEditingController());
    when(viewModel.passphraseFocusNode).thenReturn(FocusNode());
    when(viewModel.passwordController).thenReturn(TextEditingController());
    when(viewModel.passphraseFocusNode).thenReturn(FocusNode());

    final widget = TwoFactorAuthDisableView(
      viewModel,
    );

    final testwidget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: widget,
    );

    await testAcrossAllDevices(
        tester, () => testwidget, 'twofa/twofa_disable_view');
  });

  testSnapshot('twofa disable mobile dark', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0001);

    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateDarkTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(true);

    final viewModel = MockTwoFactorAuthDisableViewModel();
    when(viewModel.keepAlive).thenAnswer((_) => true);
    when(viewModel.screenSizeState).thenAnswer((_) => false);
    when(viewModel.coordinator)
        .thenAnswer((_) => MockTwoFactorAuthDisableCoordinator());
    when(viewModel.datasourceChanged).thenAnswer(
      (_) => StreamController<MockSigninViewModel>.broadcast().stream,
    );
    when(viewModel.currentSize).thenAnswer((_) => ViewSize.mobile);
    when(viewModel.digitControllers)
        .thenReturn(List.generate(6, (index) => TextEditingController()));
    when(viewModel.error).thenReturn("");
    when(viewModel.passwordController).thenReturn(TextEditingController());
    when(viewModel.passphraseFocusNode).thenReturn(FocusNode());
    when(viewModel.passwordController).thenReturn(TextEditingController());
    when(viewModel.passphraseFocusNode).thenReturn(FocusNode());

    final widget = TwoFactorAuthDisableView(
      viewModel,
    );

    final testwidget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: widget,
    );

    await testAcrossAllDevices(tester, () => testwidget, 'twofa/dark_view');
  });
}

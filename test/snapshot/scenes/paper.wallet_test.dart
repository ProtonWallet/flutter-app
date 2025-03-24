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
import 'package:wallet/scenes/paper.wallet/paper.wallet.coordinator.dart';
import 'package:wallet/scenes/paper.wallet/paper.wallet.view.dart';
import 'package:wallet/scenes/paper.wallet/paper.wallet.viewmodel.dart';

import '../../mocks/theme.provider.mocks.dart';
import '../helper/comparator.config.dart';
import '../helper/test.wrapper.dart';
import 'paper.wallet_test.mocks.dart';
import 'signin_test.mocks.dart';

@GenerateMocks([
  PaperWalletViewModel,
  PaperWalletCoordinator,
])
void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('paper wallet mobile', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0001);
    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateLightTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(false);

    final viewModel = MockPaperWalletViewModel();
    when(viewModel.keepAlive).thenAnswer((_) => true);
    when(viewModel.screenSizeState).thenAnswer((_) => false);
    when(viewModel.pageStatus).thenAnswer((_) => PageStatus.importPaperWallet);
    when(viewModel.privateKeyController)
        .thenAnswer((_) => TextEditingController(text: "mock private key"));
    when(viewModel.privateKeyFocusNode).thenAnswer((_) => FocusNode());
    when(viewModel.importedError)
        .thenAnswer((_) => "Invalid private key. Please try again.");
    when(viewModel.coordinator).thenAnswer((_) => MockPaperWalletCoordinator());
    when(viewModel.datasourceChanged).thenAnswer(
      (_) => StreamController<MockSigninViewModel>.broadcast().stream,
    );
    when(viewModel.currentSize).thenAnswer((_) => ViewSize.mobile);

    final widget = PaperWalletView(
      viewModel,
    );

    final testwidget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: widget,
    );

    await testAcrossAllDevices(
        tester, () => testwidget, 'paper.wallet/paper.wallet.view');
  });

  testSnapshot('paper wallet mobile dark', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0001);

    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateDarkTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(true);

    final viewModel = MockPaperWalletViewModel();
    when(viewModel.keepAlive).thenAnswer((_) => true);
    when(viewModel.screenSizeState).thenAnswer((_) => false);
    when(viewModel.pageStatus).thenAnswer((_) => PageStatus.importPaperWallet);
    when(viewModel.privateKeyController)
        .thenAnswer((_) => TextEditingController(text: "mock private key"));
    when(viewModel.privateKeyFocusNode).thenAnswer((_) => FocusNode());
    when(viewModel.importedError)
        .thenAnswer((_) => "Invalid private key. Please try again.");
    when(viewModel.coordinator).thenAnswer((_) => MockPaperWalletCoordinator());
    when(viewModel.datasourceChanged).thenAnswer(
      (_) => StreamController<MockSigninViewModel>.broadcast().stream,
    );
    when(viewModel.currentSize).thenAnswer((_) => ViewSize.mobile);

    final widget = PaperWalletView(
      viewModel,
    );

    final testwidget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: widget,
    );

    await testAcrossAllDevices(
        tester, () => testwidget, 'paper.wallet/paper.wallet.dark.view');
  });
}

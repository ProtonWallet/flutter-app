import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/welcome/welcome.view.dart';

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

    await testAcrossAllDevices(tester, () => widget, 'welcome/welcome_view');
  });
}

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/unavailable/unavailable.view.dart';

import '../../mocks/buying.unavailable.mocks.dart';
import '../helper/comparator.config.dart';
import '../helper/test.wrapper.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('buying unavailable tests', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0001);

    final viewModel = MockBuyingUnavailableViewModel();
    when(viewModel.keepAlive).thenAnswer((_) => true);
    when(viewModel.screenSizeState).thenAnswer((_) => false);
    when(viewModel.coordinator)
        .thenAnswer((_) => MockBuyingUnavailableCoordinator());
    when(viewModel.datasourceChanged).thenAnswer(
      (_) =>
          StreamController<MockBuyingUnavailableViewModel>.broadcast().stream,
    );
    when(viewModel.currentSize).thenAnswer((_) => ViewSize.mobile);

    when(viewModel.showProducts).thenAnswer((_) => false);

    final widget = UnavailableView(
      viewModel,
    );
    await testAcrossAllDevices(
        tester, () => widget, 'home.v3/subview/buying.unavailable');
  });
}

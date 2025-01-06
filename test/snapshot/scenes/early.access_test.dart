import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/home.v3/sub.views/early.access/early.access.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/early.access/early.access.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/early.access/early.access.viewmodel.dart';

import '../helper/comparator.config.dart';
import '../helper/test.wrapper.dart';
import 'early.access_test.mocks.dart';

@GenerateMocks([
  EarlyAccessViewModel,
  EarlyAccessCoordinator,
])
void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('early access ios without products', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0001);

    final viewModel = MockEarlyAccessViewModel();
    when(viewModel.keepAlive).thenAnswer((_) => true);
    when(viewModel.screenSizeState).thenAnswer((_) => false);
    when(viewModel.coordinator).thenAnswer((_) => MockEarlyAccessCoordinator());
    when(viewModel.datasourceChanged).thenAnswer(
      (_) => StreamController<MockEarlyAccessViewModel>.broadcast().stream,
    );
    when(viewModel.currentSize).thenAnswer((_) => ViewSize.mobile);

    when(viewModel.email).thenAnswer((_) => "test_user@proton.me");
    when(viewModel.showProducts).thenAnswer((_) => false);

    final widget = EarlyAccessView(
      viewModel,
    );
    await testAcrossAllDevices(
        tester, () => widget, 'home.v3/subview/early_access_without_products');
  });

  testSnapshot('early access with products', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0001);

    final viewModel = MockEarlyAccessViewModel();
    when(viewModel.keepAlive).thenAnswer((_) => true);
    when(viewModel.screenSizeState).thenAnswer((_) => false);
    when(viewModel.coordinator).thenAnswer((_) => MockEarlyAccessCoordinator());
    when(viewModel.datasourceChanged).thenAnswer(
      (_) => StreamController<MockEarlyAccessViewModel>.broadcast().stream,
    );
    when(viewModel.currentSize).thenAnswer((_) => ViewSize.mobile);

    when(viewModel.email).thenAnswer((_) => "test_user@proton.me");
    when(viewModel.showProducts).thenAnswer((_) => true);

    final widget = EarlyAccessView(
      viewModel,
    );
    await testAcrossAllDevices(
        tester, () => widget, 'home.v3/subview/early_access_with_products');
  });
}

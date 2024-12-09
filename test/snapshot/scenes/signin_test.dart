import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/signin/signin.coordinator.dart';
import 'package:wallet/scenes/signin/signin.view.dart';
import 'package:wallet/scenes/signin/signin.viewmodel.dart';

import '../helper/comparator.config.dart';
import '../helper/test.wrapper.dart';
import 'signin_test.mocks.dart';

@GenerateMocks([
  SigninViewModel,
  SigninCoordinator,
])
void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('signin mobile', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0006);

    final viewModel = MockSigninViewModel();
    when(viewModel.keepAlive).thenAnswer((_) => true);
    when(viewModel.screenSizeState).thenAnswer((_) => false);
    when(viewModel.coordinator).thenAnswer((_) => MockSigninCoordinator());
    when(viewModel.datasourceChanged).thenAnswer(
      (_) => StreamController<MockSigninViewModel>.broadcast().stream,
    );
    when(viewModel.errorMessage).thenAnswer((_) => "");
    when(viewModel.currentSize).thenAnswer((_) => ViewSize.mobile);

    final widget = SigninView(
      viewModel,
    );
    await testAcrossAllDevices(tester, () => widget, 'signin/signin_view');
  });
}

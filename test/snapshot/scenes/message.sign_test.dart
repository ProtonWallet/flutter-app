import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/scenes/message.sign/message.sign.view.dart';
import 'package:wallet/scenes/message.sign/message.sign.viewmodel.dart';

import '../helper/comparator.config.dart';
import '../helper/test.wrapper.dart';
import '../helper/theme.dart';
import '../helper/widget.ext.dart';
import 'message.sign_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MessageSignViewModel>(),
])
void main() {
  const testPath = 'message.sign';
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('message sign mobile message test', (tester) async {
    setGoldenFileComparatorWithThreshold(0.003);

    final viewModel = MockMessageSignViewModel();
    final messageController = TextEditingController();
    when(viewModel.messageController).thenAnswer((_) => messageController);
    messageController.text = "Message to sign!";
    when(viewModel.address)
        .thenAnswer((_) => "bc1q9v9gk3df8c6unrhw9pzdw7fclu45n9rwwxx7z5");
    final widget = MessageSignView(
      viewModel,
    ).withTheme(lightTheme());

    await testAcrossAllDevices(tester, () => widget.withBgSecondary,
        '$testPath/$testPath.message.view');
  });

  testSnapshot('message sign mobile message hint test', (tester) async {
    setGoldenFileComparatorWithThreshold(0.003);

    final viewModel = MockMessageSignViewModel();
    final messageController = TextEditingController();
    when(viewModel.messageController).thenAnswer((_) => messageController);
    when(viewModel.address)
        .thenAnswer((_) => "bc1q9v9gk3df8c6unrhw9pzdw7fclu45n9rwwxx7z5");
    final widget = MessageSignView(
      viewModel,
    ).withTheme(lightTheme());

    await testAcrossAllDevices(tester, () => widget.withBgSecondary,
        '$testPath/$testPath.message.hint.view');
  });

  testSnapshot('message sign mobile message dark test', (tester) async {
    setGoldenFileComparatorWithThreshold(0.003);

    final viewModel = MockMessageSignViewModel();
    final messageController = TextEditingController();
    when(viewModel.messageController).thenAnswer((_) => messageController);
    messageController.text = "Message to sign!";
    when(viewModel.address)
        .thenAnswer((_) => "bc1q9v9gk3df8c6unrhw9pzdw7fclu45n9rwwxx7z5");
    final widget = MessageSignView(
      viewModel,
    ).withTheme(darkTheme());

    await testAcrossAllDevices(tester, () => widget.withBgSecondary,
        '$testPath/$testPath.message.dark.view');
  });

  testSnapshot('message sign mobile message hint dark test', (tester) async {
    setGoldenFileComparatorWithThreshold(0.003);

    final viewModel = MockMessageSignViewModel();
    final messageController = TextEditingController();
    when(viewModel.messageController).thenAnswer((_) => messageController);
    when(viewModel.address)
        .thenAnswer((_) => "bc1q9v9gk3df8c6unrhw9pzdw7fclu45n9rwwxx7z5");
    final widget = MessageSignView(
      viewModel,
    ).withTheme(darkTheme());

    await testAcrossAllDevices(tester, () => widget.withBgSecondary,
        '$testPath/$testPath.message.hint.dark.view');
  });

  testSnapshot('message sign mobile signature test', (tester) async {
    setGoldenFileComparatorWithThreshold(0.003);

    final viewModel = MockMessageSignViewModel();
    final signature = TextEditingController();
    signature.text =
        "JwAjPCrPbYLiWJU0fJzkZ+5rpbDot5gpk/MliZZLv49+M8FbgLXXImpsvWVWT6m0BL6Z87lS6KZGgF9ScAab+2Y=";
    when(viewModel.messageController)
        .thenAnswer((_) => TextEditingController());
    when(viewModel.signatureController).thenAnswer((_) => signature);
    when(viewModel.showSignature).thenReturn(true);

    final widget = MessageSignView(
      viewModel,
    ).withTheme(lightTheme());
    await testAcrossAllDevices(tester, () => widget.withBgSecondary,
        '$testPath/$testPath.signature.view');
  });

  testSnapshot('message sign mobile signature dark test', (tester) async {
    setGoldenFileComparatorWithThreshold(0.003);

    final viewModel = MockMessageSignViewModel();
    final signature = TextEditingController();
    signature.text =
        "JwAjPCrPbYLiWJU0fJzkZ+5rpbDot5gpk/MliZZLv49+M8FbgLXXImpsvWVWT6m0BL6Z87lS6KZGgF9ScAab+2Y=";
    when(viewModel.messageController)
        .thenAnswer((_) => TextEditingController());
    when(viewModel.signatureController).thenAnswer((_) => signature);
    when(viewModel.showSignature).thenReturn(true);

    final widget = MessageSignView(
      viewModel,
    ).withTheme(darkTheme());
    await testAcrossAllDevices(
      tester,
      () => widget.withBgSecondary,
      '$testPath/$testPath.signature.dark.view',
    );
  });
}

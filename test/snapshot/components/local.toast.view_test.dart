import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/scenes/components/local.toast.view.dart';

import '../../mocks/theme.provider.mocks.dart';
import '../helper/center.container.widget.dart';
import '../helper/test.wrapper.dart';

void main() {
  const testPath = 'toast.view';
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('loccal toast view tests light mode', (tester) async {
    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateLightTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(false);

    final widget = buildTestContent(mockThemeProvider);
    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/$testPath.light",
    );
  });

  testSnapshot('loccal toast view tests dark mode', (tester) async {
    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateDarkTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(true);
    final widget = buildTestContent(mockThemeProvider);
    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/$testPath.dark",
    );
  });
}

Widget buildTestContent(MockThemeProvider mockThemeProvider) {
  final height = 70.0;
  final message = "Copied address, Sampel msg etc ...";
  final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
    ..addScenario(
      'Sample ',
      CenterContainer(
        height: height,
        child: ToastView(
          toastType: ToastType.norm,
          icon: const Icon(Icons.check),
          message: message,
        ),
      ),
    )
    ..addScenario(
      'Sample ',
      CenterContainer(
        height: height,
        child: ToastView(
          toastType: ToastType.warning,
          icon: const Icon(Icons.check),
          message: message,
        ),
      ),
    )
    ..addScenario(
      'Sample ',
      CenterContainer(
        height: height,
        child: ToastView(
          toastType: ToastType.norm,
          icon: const Icon(Icons.check_box),
          message: message,
        ),
      ),
    )
    ..addScenario(
      'Sample ',
      CenterContainer(
        height: height,
        child: ToastView(
          toastType: ToastType.warning,
          message: message,
        ),
      ),
    )
    ..addScenario(
      'Sample ',
      CenterContainer(
        height: height,
        child: ToastView(
          toastType: ToastType.norm,
          message: message,
        ),
      ),
    );
  final widget = ChangeNotifierProvider<ThemeProvider>.value(
    value: mockThemeProvider,
    child: builder.build(),
  );
  return widget;
}

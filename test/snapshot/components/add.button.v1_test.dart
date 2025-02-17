import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/provider/theme.provider.dart';
import 'package:wallet/scenes/components/add.button.v1.dart';

import '../../mocks/theme.provider.mocks.dart';
import '../helper/test.wrapper.dart';

void main() {
  const testPath = 'add.button.v1';
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('Add button v1 checks', (tester) async {
    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateLightTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(false);

    final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
      ..addScenario(
        'Sample add button v1',
        Row(
          children: [const AddButtonV1()],
        ),
      );

    final widget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: builder.build(),
    );

    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/add.button.v1.grid",
    );
  });

  testSnapshot('Add button v1 checks dark', (tester) async {
    final mockThemeProvider = MockThemeProvider();
    ProtonColors.updateDarkTheme();
    when(mockThemeProvider.isDarkMode()).thenReturn(true);

    final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
      ..addScenario(
        'Sample add button v1',
        Row(
          children: [const AddButtonV1()],
        ),
      );

    final widget = ChangeNotifierProvider<ThemeProvider>.value(
      value: mockThemeProvider,
      child: builder.build(),
    );

    await testAcrossAllDevices(
      tester,
      () => widget,
      "$testPath/dark.grid",
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/components/add.button.v1.dart';

import '../../mocks/theme.provider.mocks.dart';
import '../helper/test.wrapper.dart';
import '../helper/theme.dart';
import '../helper/widget.ext.dart';

void main() {
  const testPath = 'add.button.v1';
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('Add button v1 checks', (tester) async {
    final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
      ..addScenario(
        'Sample add button v1',
        Row(
          children: [const AddButtonV1()],
        ),
      );

    await testAcrossAllDevices(
      tester,
      () => builder.build().withTheme(lightTheme()),
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

    await testAcrossAllDevices(
      tester,
      () => builder.build().withTheme(darkTheme()),
      "$testPath/dark.grid",
    );
  });
}

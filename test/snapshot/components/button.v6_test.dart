import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:wallet/constants/fonts.gen.dart';
import 'package:wallet/scenes/components/button.v6.dart';

import '../helper/test.wrapper.dart';

void main() {
  const testPath = 'button.v6';
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('Button v6 general checks', (tester) async {
    final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
      ..addScenario(
          'Sample 300 x 80',
          const ButtonV6(
            text: 'Sample 300 x 80',
            width: 300,
            height: 80,
            isLoading: false,
          ))
      ..addScenario(
          'Sample 300 x 60',
          const ButtonV6(
            text: 'Sample 300 x 60',
            width: 300,
            height: 60,
          ))
      ..addScenario(
          'Sample 300 x 60 long text',
          const ButtonV6(
            text:
                'Sample 300 x 60 long text long text long text long text long text long text long text long text long text long text long text long text long text long text long text long text long text long text long text long text ',
            width: 300,
            height: 60,
          ))
      ..addScenario(
          'Sample 300 x 60, Radius 10',
          const ButtonV6(
            text: 'Sample 300 x 60, Radius 10',
            width: 300,
            height: 60,
            radius: 10,
          ))
      ..addScenario(
          'Sample 300 x 60, enable = false',
          const ButtonV6(
            text: 'Sample 300 x 60, enable = false',
            width: 300,
            height: 60,
            enable: false,
          ))
      ..addScenario(
          'Sample 300 x 60,Red',
          const ButtonV6(
            text: 'Sample 300 x 60, Red',
            width: 300,
            height: 60,
            backgroundColor: Colors.red,
          ));
    await tester.pumpWidgetBuilder(
      builder.build(),
      wrapper: materialAppWrapper(
        theme: ThemeData(
          fontFamily: FontFamily.inter,
        ),
      ),
      surfaceSize: const Size(600, 800),
    );
    await screenMatchesGolden(
      tester,
      "$testPath/button.v6.grid",
    );
  });

  testSnapshot('Button v6 device sizes checks', (tester) async {
    final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
      ..addScenario(
          'Sample 300 x 80',
          const ButtonV6(
            text: 'Sample 300 x 80',
            width: 300,
            height: 80,
            isLoading: false,
          ))
      ..addScenario(
          'Sample 300 x 60',
          const ButtonV6(
            text: 'Sample 300 x 60',
            width: 300,
            height: 60,
          ))
      ..addScenario(
          'Sample 300 x 60 long text',
          const ButtonV6(
            text:
                'Sample 300 x 60 long text long text long text long text long text long text long text long text long text long text long text long text long text long text long text long text long text long text long text long text ',
            width: 300,
            height: 60,
          ))
      ..addScenario(
          'Sample 300 x 60, Radius 10',
          const ButtonV6(
            text: 'Sample 300 x 60, Radius 10',
            width: 300,
            height: 60,
            radius: 10,
          ))
      ..addScenario(
          'Sample 300 x 60, enable = false',
          const ButtonV6(
            text: 'Sample 300 x 60, enable = false',
            width: 300,
            height: 60,
            enable: false,
          ))
      ..addScenario(
          'Sample 300 x 60,Red',
          const ButtonV6(
            text: 'Sample 300 x 60, Red',
            width: 300,
            height: 60,
            backgroundColor: Colors.red,
          ));

    await testAcrossAllDevices(
      tester,
      builder.build,
      "$testPath/button.v6.grid",
    );
  });
}

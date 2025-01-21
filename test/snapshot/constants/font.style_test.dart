import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:wallet/constants/fonts.gen.dart';
import 'package:wallet/constants/text.style.dart';
import 'package:wallet/scenes/components/button.v6.dart';

import '../helper/test.wrapper.dart';

void main() {
  const testPath = 'font.style';
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('Proton Text style general checks x3 scale', (tester) async {
    final builder = GoldenBuilder.grid(
        columns: 1, widthToHeightRatio: 1, bgColor: Colors.white)
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example',
              style: ProtonStyles.hero(),
            ),
          ))
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example',
              style: ProtonStyles.headline(),
            ),
          ))
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example',
              style: ProtonStyles.subheadline(),
            ),
          ))
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example',
              style: ProtonStyles.body1Semibold(),
            ),
          ))
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example',
              style: ProtonStyles.body1Medium(),
            ),
          ))
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example',
              style: ProtonStyles.body1Regular(),
            ),
          ))
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example',
              style: ProtonStyles.body2Semibold(),
            ),
          ))
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example',
              style: ProtonStyles.body2Medium(),
            ),
          ))
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example',
              style: ProtonStyles.body2Regular(),
            ),
          ))
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example',
              style: ProtonStyles.captionSemibold(),
            ),
          ))
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example',
              style: ProtonStyles.captionMedium(),
            ),
          ))
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example',
              style: ProtonStyles.captionRegular(),
            ),
          ))
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example',
              style: ProtonStyles.overlineMedium(),
            ),
          ))
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example',
              style: ProtonStyles.overlineRegular(),
            ),
          ));
    await tester.pumpWidgetBuilder(
      builder.build(),
      wrapper: materialAppWrapper(
        theme: ThemeData(
          fontFamily: FontFamily.inter,
        ),
      ),
      surfaceSize: const Size(1200, 2500),
      textScaleSize: 3.0,
    );
    await screenMatchesGolden(
      tester,
      "$testPath/font.style.grid",
    );
  });

  testSnapshot('Proton Text Wallet Style general', (tester) async {
    final builder = GoldenBuilder.grid(
        columns: 1, widthToHeightRatio: 1, bgColor: Colors.white)
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example - New added',
              style: ProtonWalletStyles.twoFACode(),
            ),
          ))
      ..addScenario(
          '',
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              'This is the text style example - New added',
              style: ProtonWalletStyles.textAmount(),
            ),
          ));
    await tester.pumpWidgetBuilder(
      builder.build(),
      wrapper: materialAppWrapper(
        theme: ThemeData(
          fontFamily: FontFamily.inter,
        ),
      ),
      surfaceSize: const Size(1200, 2500),
      textScaleSize: 3.0,
    );
    await screenMatchesGolden(
      tester,
      "$testPath/font.style.wallet.grid",
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

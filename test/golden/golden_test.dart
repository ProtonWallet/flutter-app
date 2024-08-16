import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:wallet/constants/fonts.gen.dart';
import 'package:wallet/scenes/components/button.v6.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('Weather types should look correct', skip: false, (tester) async {
    final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
      ..addScenario(
          'Sunny1',
          const ButtonV6(
            text: 'Sunny',
            width: 300,
            height: 80,
            isLoading: false,
          ))
      ..addScenario(
          'Cloudy',
          const ButtonV6(
            text: 'Cloudy',
            width: 300,
            height: 60,
          ))
      ..addScenario(
          'Raining',
          const ButtonV6(
            text: 'Rainin123123123123g',
            width: 300,
            height: 60,
          ))
      ..addScenario(
          'K 中文 测试 !!lkj@!#@!@#',
          const ButtonV6(
            text: 'K 中文 测试 !!lkj@!#@!@#',
            width: 300,
            height: 60,
          ))
      ..addScenario(
          'Cold',
          const ButtonV6(
            text: 'Cold',
            width: 300,
            height: 60,
          ));
    await tester.pumpWidgetBuilder(
      builder.build(),
      wrapper: materialAppWrapper(
        theme: ThemeData(
          fontFamily: FontFamily.inter,
        ),
      ),
    );
    await screenMatchesGolden(tester, 'buttonv6_types_grid');
  }, tags: ['golden']);
}

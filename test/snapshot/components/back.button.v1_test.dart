import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/components/back.button.v1.dart';

import '../helper/test.wrapper.dart';
import '../helper/theme.dart';
import '../helper/widget.ext.dart';

void main() {
  const testPath = 'back.button.v1';
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('Alert warning tests', (tester) async {
    final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
      ..addScenario(
        'Sample with on pressed',
        Row(children: [
          BackButtonV1(
            onPressed: () {},
          ),
        ]),
      )
      ..addScenario(
        'Sample with background color',
        Row(children: [
          BackButtonV1(
            backgroundColor: ProtonColors.backgroundNorm,
            onPressed: () {},
          ),
        ]),
      )
      ..addScenario(
        'Sample with background color',
        Row(children: [
          BackButtonV1(
            backgroundColor: ProtonColors.avatarBlue1Background,
            onPressed: () {},
          ),
        ]),
      );

    await testAcrossAllDevices(
      tester,
      () => builder.build().withTheme(lightTheme()),
      "$testPath/back.button.v1.grid",
    );
  });
}

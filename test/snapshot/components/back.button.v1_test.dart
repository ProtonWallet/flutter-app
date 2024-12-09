import 'package:flutter/src/widgets/basic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/components/back.button.v1.dart';

import '../helper/test.wrapper.dart';

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
              backgroundColor: ProtonColors.backgroundProton,
              onPressed: () {},
            ),
          ]));

    await testAcrossAllDevices(
      tester,
      builder.build,
      "$testPath/back.button.v1.grid",
    );
  });
}

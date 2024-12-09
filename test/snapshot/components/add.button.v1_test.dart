import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:wallet/scenes/components/add.button.v1.dart';

import '../helper/test.wrapper.dart';

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
          ));
    await testAcrossAllDevices(
      tester,
      builder.build,
      "$testPath/add.button.v1.grid",
    );
  });
}

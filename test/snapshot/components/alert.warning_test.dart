import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:wallet/scenes/components/alert.warning.dart';

import '../helper/comparator.config.dart';
import '../helper/test.wrapper.dart';
import '../helper/theme.dart';
import '../helper/widget.ext.dart';

void main() {
  const testPath = 'alert.warning';
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('Alert warning tests', (tester) async {
    setGoldenFileComparatorWithThreshold(0.0035);
    final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
      ..addScenario(
          'Sample passphrase alert warning 350w',
          AlertWarning(
            content:
                "Store your passphrase at a safe location. Without the passphrase, even Proton cannot recover your funds.",
            width: 350,
          ))
      ..addScenario(
          'Sample passphrase alert warning 300w',
          AlertWarning(
            content:
                "Store your passphrase at a safe location. Without the passphrase, even Proton cannot recover your funds.",
            width: 300,
          ))
      ..addScenario(
          'Sample passphrase alert warning 200w',
          AlertWarning(
            content:
                "Store your passphrase at a safe location. Without the passphrase, even Proton cannot recover your funds.",
            width: 200,
          ));

    await testAcrossAllDevices(
      tester,
      () => builder.build().withTheme(lightTheme()),
      "$testPath/alert.warning.grid",
    );
  });
}

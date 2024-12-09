import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:wallet/scenes/components/alert.warning.dart';

import '../helper/test.wrapper.dart';

void main() {
  const testPath = 'alert.warning';
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('Alert warning tests', (tester) async {
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
      builder.build,
      "$testPath/alert.warning.grid",
    );
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:wallet/constants/assets.gen.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/components/alert.custom.dart';

import '../helper/test.wrapper.dart';

void main() {
  const testPath = 'alert.custom';
  setUpAll(() async {
    await loadAppFonts();
  });

  testSnapshot('Alert custom tests', (tester) async {
    final builder = GoldenBuilder.grid(columns: 1, widthToHeightRatio: 1)
      ..addScenario(
        'Sample delete wallet alert custom',
        AlertCustom(
          content:
              "This wallet seems to still have assets. We recommend you send the assets to another wallet before deleting.",
          canClose: false,
          leadingWidget: Assets.images.icon.alertWarning.svg(
            width: 22,
            height: 22,
            fit: BoxFit.fill,
          ),
          border: Border.all(
            color: Colors.transparent,
            width: 0,
          ),
          backgroundColor: ProtonColors.errorBackground,
          color: ProtonColors.signalError,
        ),
      )
      ..addScenario(
          'Sample delete wallet account alert custom',
          AlertCustom(
            content:
                "This account seems to still have assets. We recommend you send the assets to another account before deleting.",
            canClose: false,
            leadingWidget: Assets.images.icon.alertWarning.svg(
              width: 22,
              height: 22,
              fit: BoxFit.fill,
            ),
            border: Border.all(
              color: Colors.transparent,
              width: 0,
            ),
            backgroundColor: ProtonColors.errorBackground,
            color: ProtonColors.signalError,
          ))
      ..addScenario(
          'Sample delete wallet account alert custom',
          AlertCustom(
            content:
                "This account seems to still have assets. We recommend you send the assets to another account before deleting.",
            canClose: true,
            learnMore: Text("Learn More"),
            leadingWidget: Assets.images.icon.alertWarning.svg(
              width: 22,
              height: 22,
              fit: BoxFit.fill,
            ),
            backgroundColor: ProtonColors.errorBackground,
            onTap: () {},
          ))
      ..addScenario(
          'Sample delete wallet account alert custom',
          AlertCustom(
            content:
                "This account seems to still have assets. We recommend you send the assets to another account before deleting.",
            canClose: true,
            learnMore: Text("Learn More"),
            leadingWidget: Assets.images.icon.alertWarning.svg(
              width: 22,
              height: 22,
              fit: BoxFit.fill,
            ),
          ));
    await testAcrossAllDevices(
      tester,
      builder.build,
      "$testPath/alert.custom.grid",
    );
  });
}

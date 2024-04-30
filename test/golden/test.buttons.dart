import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:wallet/scenes/components/button.v6.dart';

Future<void> main() async {
  group('Basic Goldens', () {
    ///
    setUpAll(() async {});

    /// This test uses .pumpWidgetBuilder to automatically set up
    /// the appropriate Material dependencies in order to minimize boilerplate.
    ///
    /// It simply pumps a custom widget and captures the golden
    testGoldens('Weather types should look correct', skip: false,
        (tester) async {
      final builder = GoldenBuilder.grid(columns: 2, widthToHeightRatio: 1)
        ..addScenario(
            'Sunny',
            const ButtonV6(
              text: 'Sunny',
              width: 100,
              height: 100,
            ))
        ..addScenario(
            'Cloudy',
            const ButtonV6(
              text: 'Cloudy',
              width: 100,
              height: 100,
            ))
        ..addScenario(
            'Raining',
            const ButtonV6(
              text: 'Raining',
              width: 100,
              height: 100,
            ))
        ..addScenario(
            'Cold',
            const ButtonV6(
              text: 'Cold',
              width: 100,
              height: 100,
            ));
      await tester.pumpWidgetBuilder(builder.build());
      await screenMatchesGolden(tester, 'weather_types_grid', skip: false);
    });
  });
}

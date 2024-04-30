import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/managers/secure.storage/secure.storage.interface.dart';
import 'package:wallet/rust/frb_generated.dart';
import 'package:wallet/scenes/app/app.coordinator.dart' show AppCoordinator;
import 'package:wallet/scenes/buy/buybitcoin.coordinator.dart';
import 'package:wallet/scenes/components/button.v6.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';

import 'device.dart';
import 'test.mocks.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

//works with --- command: make build-runner
@GenerateMocks([
  SecureStorageInterface,
  WelcomeCoordinator,
  BuyBitcoinCoordinator,
])
void main() {
  late MockSecureStorageInterface mockStorage;
  late MockSharedPreferences mockPrefs;
  // late MockBuyBitcoinCoordinator mockBuyBitcoinCoordinator;

  setUp(() {
    RustLib.init();
    mockStorage = MockSecureStorageInterface();
    mockPrefs = MockSharedPreferences();
    // mockBuyBitcoinCoordinator = MockBuyBitcoinCoordinator();
    when(mockStorage.read('sessionId')).thenAnswer((_) async => "");
    when(mockPrefs.getString("")).thenReturn("");
    SharedPreferences.setMockInitialValues({}); // Important for initialization
    SecureStorageHelper.init(mockStorage);
  });

  Future<void> testAcrossAllDevices(
    WidgetTester tester,
    Widget Function() buildWidget,
    String testName,
  ) async {
    for (final device in devicesWithDifferentTextScales) {
      final fileName = '${testName}_${device.name}';
      await tester.pumpWidgetBuilder(
        buildWidget(),
        wrapper: materialAppWrapper(
          theme: ThemeData
              .light(), // Ensure the ThemeData is correctly wrapped around your app
        ),
        surfaceSize: device.size,
      );
      await screenMatchesGolden(tester, fileName);
    }
  }

  // testGoldens('AppCoordinator Golden Test', (WidgetTester tester) async {
  //   await testAcrossAllDevices(
  //       tester, () => AppCoordinator().start(), 'app_coordinator');
  // });

  // testGoldens('BuyBitcoinCoordinator Golden Test', (WidgetTester tester) async {
  //   // Assuming start() returns a Widget, directly testing it
  //   // var widget = BuyBitcoinCoordinator().start(); // This needs to return a Widget
  //   // //todo: mock properly BuyBitcoinCoordinator to show the screen with some realistic data
  //   // await testAcrossAllDevices(tester, () => widget, 'buy_bitcoin_coordinator');
  // });

  testGoldens('Weather types should look correct', (tester) async {
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
    await screenMatchesGolden(tester, 'weather_types_grid');
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/scenes/app/app.coordinator.dart';

class MockSecureStorageHelper extends Mock implements SecureStorageHelper {
  @override
  Future<String?> get(String key) async {
    // This will be configured in your tests
  }
}


void main() {
  testGoldens('AppCoordinator Golden Test', (WidgetTester tester) async {
    final builder = DeviceBuilder()
      ..overrideDevicesForAllScenarios(devices: [
        // Add devices you want to test on.
        // This is an example using predefined devices from golden_toolkit:
        Device.phone,
      ])
      ..addScenario(
        name: 'Default Start',
        widget: AppCoordinator().start(),
        // You can add more scenarios here
      );

    await tester.pumpDeviceBuilder(builder);
    await tester.pumpAndSettle();

    // Here you will compare the actual rendering to the golden files
    await multiScreenGolden(tester, 'app_coordinator_start');
    await screenMatchesGolden(tester, 'test/screenshots/flutter_demo_page_multiple_scenarios');
  });
}
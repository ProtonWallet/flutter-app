import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/managers/secure.storage/secure.storage.interface.dart';
import 'package:wallet/scenes/app/app.coordinator.dart';

import 'test.mocks.dart';

// class MockSecureStorageHelper extends Mock implements SecureStorageInterface {
//   // Future<String?> get(String key) async {
//   //   return null;
//   //   // This will be configured in your tests
//   // }
// }

//works with --- command: make build-runner
@GenerateMocks([SecureStorageInterface])
void main() {
  late MockSecureStorageInterface mockStorage;
  setUp(() {
    mockStorage = MockSecureStorageInterface();
  });

  testGoldens('AppCoordinator Golden Test', (WidgetTester tester) async {
    when(mockStorage.read('sessionId')).thenAnswer((_) async => "");

    SecureStorageHelper.init(mockStorage);
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
    await screenMatchesGolden(
        tester, 'test/screenshots/flutter_demo_page_multiple_scenarios');
  });
}

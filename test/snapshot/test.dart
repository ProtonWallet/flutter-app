import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/managers/secure.storage/secure.storage.interface.dart';
import 'package:wallet/rust/frb_generated.dart';
import 'package:wallet/scenes/buy/buybitcoin.coordinator.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';

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
}

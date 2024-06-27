import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:wallet/helper/user.agent.dart';

import 'user.agent_test.mocks.dart';

@GenerateMocks([
  DeviceInfoPlugin,
  PackageInfo,
  IosDeviceInfo,
  AndroidDeviceInfo,
  MacOsDeviceInfo,
  IosUtsname,
  AndroidBuildVersion,
  LinuxDeviceInfo,
  WindowsDeviceInfo,
])
void main() {
  group('UserAgent Tests', () {
    final mockDeviceInfo = MockDeviceInfoPlugin();
    final mockPackageInfo = MockPackageInfo();
    final mockIosInfo = MockIosDeviceInfo();
    final mockAndroidInfo = MockAndroidDeviceInfo();
    final mockMacOsInfo = MockMacOsDeviceInfo();
    final mockLinuxDeviceInfo = MockLinuxDeviceInfo();
    final mockWindowsDeviceInfo = MockWindowsDeviceInfo();

    final mockIosUtsname = MockIosUtsname();
    final mockAndroidBuildVersion = MockAndroidBuildVersion();

    setUp(() {
      // Mock the package info as needed for the tests
      when(mockPackageInfo.appName).thenReturn('Proton Wallet');
      when(mockPackageInfo.version).thenReturn('1.0.0');
      when(mockPackageInfo.buildNumber).thenReturn('33');
    });

    test('User agent string on Linux', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;

      /// setup mocks
      when(mockLinuxDeviceInfo.name).thenReturn('Ubuntu');
      when(mockLinuxDeviceInfo.version).thenReturn('20.04');
      when(mockLinuxDeviceInfo.id).thenReturn('ubuntu');
      when(mockLinuxDeviceInfo.prettyName).thenReturn('Ubuntu 20.04 LTS');
      when(mockLinuxDeviceInfo.machineId).thenReturn('1234567890');
      when(mockDeviceInfo.linuxInfo).thenAnswer(
        (_) async => Future.value(mockLinuxDeviceInfo),
      );

      final userAgent = UserAgent(
        deviceInfo: mockDeviceInfo,
        packageInfo: Future.value(mockPackageInfo),
      );
      final ua = await userAgent.ua;
      expect(ua, 'ProtonWallet/1.0.0 (Ubuntu 20.04; Ubuntu 20.04 LTS)');
      final appVersion = await userAgent.appVersion;
      expect(appVersion, "linux-wallet@1.0.0");
      final display = await userAgent.display;
      expect(display, "Proton Wallet 1.0.0 (33)");
    });

    test('User agent string on macOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;

      /// setup mocks
      when(mockMacOsInfo.model).thenReturn('MacBookPro16,1');
      when(mockMacOsInfo.osRelease).thenReturn('10.15.7');
      when(mockDeviceInfo.macOsInfo).thenAnswer(
        (_) async => Future.value(mockMacOsInfo),
      );

      final userAgent = UserAgent(
        deviceInfo: mockDeviceInfo,
        packageInfo: Future.value(mockPackageInfo),
      );
      final ua = await userAgent.ua;
      expect(ua, 'ProtonWallet/1.0.0 (macOS 10.15.7; MacBookPro16,1)');
      final appVersion = await userAgent.appVersion;
      expect(appVersion, "macos-wallet@1.0.0");
      final display = await userAgent.display;
      expect(display, "Proton Wallet 1.0.0 (33)");
    });

    test('User agent string on iOS', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      /// setup mocks for iosDeviceInfo
      when(mockIosUtsname.machine).thenReturn('iPhone8,1');
      when(mockIosInfo.systemVersion).thenReturn('14.0');
      when(mockIosInfo.utsname).thenReturn(mockIosUtsname);
      when(mockDeviceInfo.iosInfo).thenAnswer(
        (value) async => Future.value(mockIosInfo),
      );
      final userAgent = UserAgent(
        deviceInfo: mockDeviceInfo,
        packageInfo: Future.value(mockPackageInfo),
      );
      final ua = await userAgent.ua;

      expect(ua, 'ProtonWallet/1.0.0 (iOS 14.0; iPhone8,1)');
      final appVersion = await userAgent.appVersion;
      expect(appVersion, "ios-wallet@1.0.0");
      final display = await userAgent.display;
      expect(display, "Proton Wallet 1.0.0 (33)");
    });

    test('User agent string on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      /// setup mocks
      when(mockAndroidBuildVersion.release).thenReturn('11');
      when(mockAndroidInfo.version).thenReturn(mockAndroidBuildVersion);
      when(mockAndroidInfo.model).thenReturn('Pixel 4');
      when(mockDeviceInfo.androidInfo).thenAnswer(
        (_) async => Future.value(mockAndroidInfo),
      );

      final userAgent = UserAgent(
        deviceInfo: mockDeviceInfo,
        packageInfo: Future.value(mockPackageInfo),
      );
      final ua = await userAgent.ua;
      expect(ua, 'ProtonWallet/1.0.0 (Android 11; Pixel 4)');
      final appVersion = await userAgent.appVersion;
      expect(appVersion, "android-wallet@1.0.0");
      final display = await userAgent.display;
      expect(display, "Proton Wallet 1.0.0 (33)");
    });

    test('User agent string on windows', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;

      when(mockWindowsDeviceInfo.majorVersion).thenReturn(5);
      when(mockWindowsDeviceInfo.displayVersion).thenReturn("21H2");
      when(mockDeviceInfo.windowsInfo).thenAnswer(
        (_) async => Future.value(mockWindowsDeviceInfo),
      );

      /// setup mocks
      when(mockMacOsInfo.model).thenReturn('MacBookPro16,1');
      when(mockMacOsInfo.osRelease).thenReturn('10.15.7');
      when(mockDeviceInfo.windowsInfo).thenAnswer(
        (_) async => Future.value(mockWindowsDeviceInfo),
      );
      final userAgent = UserAgent(
        deviceInfo: mockDeviceInfo,
        packageInfo: Future.value(mockPackageInfo),
      );
      final ua = await userAgent.ua;
      expect(ua, 'ProtonWallet/1.0.0 (Windows 5; 21H2)');
      final appVersion = await userAgent.appVersion;
      expect(appVersion, "windows-wallet@1.0.0");
      final display = await userAgent.display;
      expect(display, "Proton Wallet 1.0.0 (33)");
    });
  });
}

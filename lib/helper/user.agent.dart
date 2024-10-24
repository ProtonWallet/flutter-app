import 'dart:async';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UserAgent {
  static final UserAgent _instance = UserAgent._internal();
  factory UserAgent({
    DeviceInfoPlugin? deviceInfo,
    Future<PackageInfo>? packageInfo,
  }) {
    _instance.deviceInfo = deviceInfo ?? DeviceInfoPlugin();
    _instance.packageInfo = packageInfo ?? PackageInfo.fromPlatform();
    return _instance;
  }

  UserAgent._internal();

  late DeviceInfoPlugin deviceInfo;
  late Future<PackageInfo> packageInfo;

  String? _cachedUA;

  String? _cachedAppVersion;
  String? _cachedDisplay;
  String? _cachedSentryRelease;

  Future<String> get ua async {
    if (_cachedUA == null) {
      return _computeUA();
    } else {
      return _cachedUA!;
    }
  }

  Future<String> get appVersion async {
    if (_cachedAppVersion == null) {
      return _computeAppVersion();
    } else {
      return _cachedAppVersion!;
    }
  }

  Future<String> get display async {
    if (_cachedDisplay == null) {
      return _computeDisplay();
    } else {
      return _cachedDisplay!;
    }
  }

  /// Sentry inital release string
  Future<String> get sentryRelease async {
    if (_cachedSentryRelease == null) {
      return _computeSentryRelease();
    } else {
      return _cachedSentryRelease!;
    }
  }

  /// format: android-wallet@2.3.12+12
  Future<String> _computeSentryRelease() async {
    final info = await packageInfo;
    final version = info.version;
    final build = info.buildNumber;
    final String platformName = _getPlatformName();
    return "$platformName-wallet@$version+$build";
  }

  ///
  Future<String> _computeDisplay() async {
    final info = await packageInfo;
    final name = info.appName.replaceAll(' ', '');
    final version = info.version;
    final build = info.buildNumber;
    var suffix = "";
    if (kDebugMode) {
      suffix = "-dev";
    }
    return "$name $version$suffix ($build)";
  }

  ///
  Future<String> _computeAppVersion() async {
    final info = await packageInfo;
    final version = info.version;
    final build = info.buildNumber;
    final String platformName = _getPlatformName();
    var suffix = "";
    if (kDebugMode) {
      suffix = "-dev";
    }
    return "$platformName-wallet@$version.$build$suffix";
  }

  String _getPlatformName() {
    String platformName = "ios";
    final TargetPlatform platform = defaultTargetPlatform;
    if (kIsWeb) {
      platformName = "web";
    } else if (platform == TargetPlatform.iOS ||
        platform == TargetPlatform.android) {
      if (platform == TargetPlatform.iOS) {
        platformName = "ios";
      } else if (platform == TargetPlatform.android) {
        platformName = "android";
      }
    } else if (platform == TargetPlatform.macOS) {
      platformName = "macos";
    } else if (platform == TargetPlatform.linux) {
      platformName = "linux";
    } else if (platform == TargetPlatform.windows) {
      platformName = "windows";
    }
    return platformName;
  }

  Future<String> _computeUA() async {
    final appNameAndVersion = await _getAppNameAndVersion();
    final deviceVersion = await _getDeviceVersion();
    final deviceName = await _getDeviceName();

    return "$appNameAndVersion ($deviceVersion; $deviceName)";
  }

  Future<String> _getAppNameAndVersion() async {
    final info = await packageInfo;
    final name = info.appName.replaceAll(' ', '');
    final version = info.version;
    return "$name/$version";
  }

  Future<String> _getDeviceVersion() async {
    final TargetPlatform platform = defaultTargetPlatform;
    if (kIsWeb) {
      return "Web";
    } else if (platform == TargetPlatform.iOS ||
        platform == TargetPlatform.android) {
      if (platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return "iOS ${iosInfo.systemVersion}";
      } else if (platform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        return "Android ${androidInfo.version.release}";
      }
    } else if (platform == TargetPlatform.macOS) {
      final macOsInfo = await deviceInfo.macOsInfo;
      return "macOS ${macOsInfo.osRelease}";
    } else if (platform == TargetPlatform.linux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      return "${linuxInfo.name} ${linuxInfo.version}";
    } else if (platform == TargetPlatform.windows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      return "Windows ${windowsInfo.majorVersion}";
    }
    return "Unknown";
  }

  Future<String> _getDeviceName() async {
    final TargetPlatform platform = defaultTargetPlatform;
    if (kIsWeb) {
      return "Browser";
    } else if (platform == TargetPlatform.iOS ||
        platform == TargetPlatform.android) {
      if (platform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.utsname.machine;
      } else if (platform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        return "${androidInfo.manufacturer} ${androidInfo.model}";
      }
    } else if (platform == TargetPlatform.macOS) {
      final macOsInfo = await deviceInfo.macOsInfo;
      return macOsInfo.model;
    } else if (platform == TargetPlatform.linux) {
      final linuxInfo = await deviceInfo.linuxInfo;
      return linuxInfo.prettyName;
    } else if (platform == TargetPlatform.windows) {
      final windowsInfo = await deviceInfo.windowsInfo;
      return windowsInfo.displayVersion;
    }
    return "Unknown";
  }
}

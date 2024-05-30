import 'dart:io';

extension PlatformExtension on Platform {
  static bool get mobile => Platform.isAndroid || Platform.isIOS;
  static bool get desktop => !mobile;
}

bool isM1Simulator() {
  if (Platform.isIOS) {
    // On iOS simulators, environment variables can help determine the architecture
    final arch = Platform.environment['SIMULATOR_RUNTIME'] ?? '';
    if (arch.contains('arm64')) {
      return true;
    }
  }
  return false;
}

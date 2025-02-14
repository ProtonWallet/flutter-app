import 'dart:io';

import 'package:flutter/foundation.dart';

bool get mobile => android || iOS;
bool get desktop => !mobile;
bool get android => defaultTargetPlatform == TargetPlatform.android;
bool get iOS => defaultTargetPlatform == TargetPlatform.iOS;
bool get macOS => defaultTargetPlatform == TargetPlatform.macOS;

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

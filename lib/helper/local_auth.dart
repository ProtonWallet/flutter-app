import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:wallet/helper/logger.dart';

class LocalAuth {
  static bool _initialized = false;
  static bool _canCheckBiometrics = false;
  static final LocalAuthentication auth = LocalAuthentication();

  static bool isPlatformSupported() {
    if (Platform.isAndroid || Platform.isIOS || Platform.isWindows) {
      return true;
    }
    logger.i(
        "${Platform.operatingSystem} is not supported platform for LocalAuth");
    return false;
  }

  static Future<void> init() async {
    if (!isPlatformSupported()) {
      return;
    }
    if (!_initialized) {
      _initialized = true;
      try {
        _canCheckBiometrics = await auth.canCheckBiometrics;
      } on PlatformException catch (e) {
        logger.e(e);
      }
    }
  }

  static Future<bool> authenticate(String hint) async {
    if (!isPlatformSupported()) {
      return false;
    }
    if (_canCheckBiometrics == false) {
      return false;
    }
    bool authenticated = false;
    try {
      authenticated = await auth.authenticate(localizedReason: hint);
    } on PlatformException catch (e) {
      logger.e(e);
      return false;
    }
    return authenticated;
  }
}

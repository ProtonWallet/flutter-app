import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/manager.dart';

class LocalAuthManager implements Manager {
  static bool _initialized = false;
  bool canCheckBiometrics = false;
  static final LocalAuthentication auth = LocalAuthentication();

  String? userID;

  static bool isPlatformSupported() {
    if (Platform.isAndroid || Platform.isIOS || Platform.isWindows) {
      return true;
    }
    logger.i(
        "${Platform.operatingSystem} is not supported platform for LocalAuth");
    return false;
  }

  @override
  Future<void> init() async {
    if (!isPlatformSupported()) {
      return;
    }
    if (!_initialized) {
      _initialized = true;
      try {
        canCheckBiometrics = await auth.canCheckBiometrics;
      } on PlatformException catch (e) {
        logger.e(e);
      }
    }
  }

  Future<bool> authenticate(String hint) async {
    if (!isPlatformSupported()) {
      return false;
    }
    if (!canCheckBiometrics) {
      return false;
    }
    // final checkable = await auth.canCheckBiometrics;
    bool authenticated = false;
    try {
      const option = AuthenticationOptions(
        biometricOnly: true,
      );
      authenticated =
          await auth.authenticate(localizedReason: hint, options: option);
    } on PlatformException catch (e) {
      logger.e(e);
      return false;
    }
    return authenticated;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> login(String userID) async {
    this.userID = userID;
  }

  @override
  Future<void> logout() async {
    userID = null;
  }
}

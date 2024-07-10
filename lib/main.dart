import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/rust/api/flutter_logger.dart';
import 'package:wallet/rust/frb_generated.dart';
import 'package:wallet/scenes/app/app.coordinator.dart';

Future setupLogger() async {
  infoLogger().listen((msg) {
    switch (msg.logLevel) {
      case Level.error:
        logger.e("${msg.lbl.padRight(8)}: ${msg.msg}");
        break;
      case Level.warn:
        logger.w("${msg.lbl.padRight(8)}: ${msg.msg}");
        break;
      case Level.info:
        logger.i("${msg.lbl.padRight(8)}: ${msg.msg}");
        break;
      case Level.debug:
        logger.d("${msg.lbl.padRight(8)}: ${msg.msg}");
        break;
      case Level.trace:
        logger.t("${msg.lbl.padRight(8)}: ${msg.msg}");
        break;
    }
    // This should use a logging framework in real applications
    // print("${msg.logLevel} ${msg.lbl.padRight(8)}: ${msg.msg}");
  });
}

void main() async {
  BindingBase.debugZoneErrorsAreFatal = true;

  /// This captures errors that occur in the Flutter framework
  /// includes: Rendering Errors, Gesture Handling Errors, Build Method Errors,
  ///   Async Errors in Flutter Widgets. in case scam our sentry.
  /// we need monitor this and see if this is ok.
  FlutterError.onError = (FlutterErrorDetails details) async {
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    } else {
      // In release mode, report to Sentry
      await Sentry.captureException(
        details.exception,
        stackTrace: details.stack,
      );
    }
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    if (kDebugMode) {
      logger.e(
        "PlatformDispatcher.instance.onError: ${error.toString()} stacktrace: ${stack.toString()}",
      );
    } else {
      // In release mode, report to Sentry
      Sentry.captureException(error, stackTrace: stack);
    }
    return true;
  };

  /// sentry init
  await Sentry.init(
      (options) => options
        ..dsn =
            'https://f430ab6a50234e50ab7fc57174de1cbc@sentry-new.protontech.ch/69'
        ..environment = appConfig.apiEnv.toString(), appRunner: () async {
    /// init everything in zone
    WidgetsFlutterBinding.ensureInitialized();
    LoggerService.initLogFile();
    AppConfig.initAppEnv();
    await RustLib.init();
    setupLogger();
    var app = AppCoordinator();
    runApp(app.start());
  });
}

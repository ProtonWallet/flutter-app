import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/env.var.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/rust/api/panic_hook.dart';
import 'package:wallet/rust/frb_generated.dart';
import 'package:wallet/scenes/app/app.coordinator.dart';

void initializePanicHandling() {
  // Listen to the stream of panic messages from Rust
  initializePanicHook().listen((message) {
    logger.e("Panic from Rust: $message");
    // Send the panic message to Sentry
    Sentry.captureMessage(message);
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
        "PlatformDispatcher.instance.onError: $error stacktrace: $stack",
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
        ..dsn = Env.sentryApiKey
        ..environment = appConfig.apiEnv.toString(), appRunner: () async {
    /// init everything in zone
    WidgetsFlutterBinding.ensureInitialized();
    // await LoggerService.initDartLogger();
    AppConfig.initAppEnv();
    await RustLib.init();

    // inital the rust panic handling
    initializePanicHandling();

    if (kDebugMode) {
      await LoggerService.initDartLogger();
      await LoggerService.initRustLogger();
    }

    // await LoggerService.initRustLogger();
    final app = AppCoordinator();
    runApp(app.start());
  });
}

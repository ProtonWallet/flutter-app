import 'package:flutter/material.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  AppConfig.initAppEnv();
  await RustLib.init();
  setupLogger();

  var app = AppCoordinator();
  runApp(app.start());
}

import 'package:flutter/material.dart';
import 'package:wallet/helper/firebase_messaging_helper.dart';
import 'package:wallet/helper/local_auth.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/rust/api/flutter_logger.dart';
import 'package:wallet/rust/frb_generated.dart';
import 'package:wallet/scenes/app/app.coordinator.dart';
import 'package:wallet/helper/local_notification.dart';

import 'helper/dbhelper.dart';

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
        // logger.i("${msg.lbl.padRight(8)}: ${msg.msg}");
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
  await LocalNotification.init();
  await FirebaseMessagingHelper.init();
  await LocalAuth.init();
  await DBHelper.init();
  SecureStorageHelper.init();
  await RustLib.init();
  await setupLogger();
  await test(i: 12);
  runApp(AppCoordinator().start());
}

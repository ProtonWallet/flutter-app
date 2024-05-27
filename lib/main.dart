import 'package:flutter/material.dart';
import 'package:wallet/helper/firebase_messaging_helper.dart';
import 'package:wallet/helper/local_auth.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/rust/api/api_service/wallet_auth_store.dart';
import 'package:wallet/rust/api/flutter_logger.dart';
import 'package:wallet/rust/frb_generated.dart';
import 'package:wallet/scenes/app/app.coordinator.dart';
import 'package:wallet/helper/local_notification.dart';

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

// TODO:: need move this to a correct place
Future testCallbackfunction() async {
  final authStore = await ProtonWalletAuthStore.newInstance();
  authStore.setDartCallback(callback: (message) {
    logger.d("Received message from Rust: $message");
    // if we have session then update auth data
    return "Reply from Dart";
  });
  logger.d("testCallbackfunction --- setup");
  await authStore.testCallback();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotification.init();
  await FirebaseMessagingHelper.init();
  await LocalAuth.init();
  await RustLib.init();
  await setupLogger();
  await testCallbackfunction();
  var app = AppCoordinator();
  await app.init();
  runApp(app.start());
}

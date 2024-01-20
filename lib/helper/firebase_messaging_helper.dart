import 'dart:io';
import 'package:wallet/helper/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'local_notification.dart';

class FirebaseMessagingHelper {
  static bool _initialized = false;

  static bool isPlatformSupported() {
    //TODO:: enable later
    if (Platform.isAndroid /*|| Platform.isIOS || Platform.isMacOS */) {
      return true;
    }
    logger.i(
        "${Platform.operatingSystem} is not supported platform for FirebaseMessagingHelper");
    return false;
  }

  static Future<void> init() async {
    if (!isPlatformSupported()) {
      return;
    }
    if (!_initialized) {
      _initialized = true;
      await Firebase.initializeApp();
      await FirebaseMessaging.instance.setAutoInitEnabled(true);

      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        logger.i("FCMToken $fcmToken");
      } catch (e) {
        logger.e("FirebaseMessaging.instance.getToken $e");
      }

      FirebaseMessaging messaging = FirebaseMessaging.instance;
      //for iOS permission settings
      NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true);
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        // will not get push notification if user don't grant permission to app
        // can show a dialog to user for this information if needed
      } else {
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
        FirebaseMessaging.instance
            .getInitialMessage()
            .then((RemoteMessage? message) {
          // receive message when app is closed, can trigger related event here
          // by default, it will show native notification in Android. need confirm for iOS
          // it will not show notification when app is terminated and it is build with debug mode in Android
        });
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          // receive message when app is open, use localNotification to inform user
          // can use local notification if needed
          LocalNotification.show(
              LocalNotification.fcmPush,
              message.notification?.title ?? "",
              message.notification?.body ?? "");
        });
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          // will be triggered after user click notification
          logger.i(
              "Got a message whilst in the onMessageOpenedApp!\n${message.notification?.title}");
        });
      }
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    logger.i("Got a message whilst in the onBackgroundMessage! \n");
  }
}

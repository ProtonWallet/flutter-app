import 'dart:async';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wallet/helper/logger.dart';

class LocalNotification {
  static const int fcmPush = 0;
  static const int syncWallet = 1;
  static final _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final StreamController<int?> selectNotificationStream =
      StreamController<int?>.broadcast();
  static bool _initialized = false;

  static bool isPlatformSupported() {
    if (Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isLinux) {
      return true;
    }
    logger.i(
        "${Platform.operatingSystem} is not supported platform for LocalNotification");
    return false;
  }

  static const androidNotificationDetail = AndroidNotificationDetails(
      '0', // channel Id
      'general' // channel Name
      );
  static const iosNotificatonDetail = DarwinNotificationDetails();
  static const notificationDetails = NotificationDetails(
    iOS: iosNotificatonDetail,
    android: androidNotificationDetail,
  );

  static Future<void> init() async {
    if (!isPlatformSupported()) {
      return;
    }
    if (!_initialized) {
      _initialized = true;
      const androidInitializationSetting =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInitializationSetting = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const initializationSettingsLinux =
          LinuxInitializationSettings(defaultActionName: 'Open notification');
      const navigationActionId = "Ok";
      const initSettings = InitializationSettings(
          android: androidInitializationSetting,
          iOS: iosInitializationSetting,
          macOS: iosInitializationSetting,
          linux: initializationSettingsLinux);
      await _flutterLocalNotificationsPlugin.initialize(initSettings,
          onDidReceiveNotificationResponse:
              (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationStream.add(notificationResponse.id);
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              selectNotificationStream.add(notificationResponse.id);
            }
        }
      });
      _listenNotificationClickEvent();
    }
  }

  static void show(int id, String title, String body) {
    if (!isPlatformSupported()) {
      return;
    }
    _flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails);
  }

  static void _listenNotificationClickEvent() {
    selectNotificationStream.stream.listen((int? id) async {
      logger.i('user clicked notification with ID = $id');
    });
  }
}

import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wallet/helper/logger.dart';

class LocalNotification {
  static final int SYNC_WALLET = 1;
  static final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final StreamController<int?> selectNotificationStream = StreamController<int?>.broadcast();
  static bool inited = false;

  static Future<void> setup() async {
    if (!inited) {
      inited = true;
      const androidInitializationSetting = AndroidInitializationSettings(
          '@mipmap/ic_launcher');
      const iosInitializationSetting = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const navigationActionId = "Ok";
      const initSettings = InitializationSettings(
          android: androidInitializationSetting, iOS: iosInitializationSetting);
      await _flutterLocalNotificationsPlugin.initialize(
          initSettings,
          onDidReceiveNotificationResponse: (
              NotificationResponse notificationResponse) {
            switch (notificationResponse.notificationResponseType) {
              case NotificationResponseType.selectedNotification:
                selectNotificationStream.add(notificationResponse.id);
                break;
              case NotificationResponseType.selectedNotificationAction:
                if (notificationResponse.actionId == navigationActionId) {
                  selectNotificationStream.add(notificationResponse.id);
                }
                break;
            }
          }
      );
      _listenNotificationClickEvent();
    }
  }

  static void show(int id, String title, String body) {
    const androidNotificationDetail = AndroidNotificationDetails(
        '0', // channel Id
        'general' // channel Name
    );
    const iosNotificatonDetail = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      iOS: iosNotificatonDetail,
      android: androidNotificationDetail,
    );
    _flutterLocalNotificationsPlugin.show(id, title, body, notificationDetails);
  }

  static void _listenNotificationClickEvent() {
    selectNotificationStream.stream.listen((int? id) async {
        logger.i('user clicked notification with ID = ${id}');
    });
  }
}
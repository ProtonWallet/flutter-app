import 'package:flutter/material.dart';
import 'package:wallet/helper/firebase_messaging_helper.dart';
import 'package:wallet/scenes/app/app.coordinator.dart';
import 'package:wallet/helper/local_notification.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await LocalNotification.init();
  await FirebaseMessagingHelper.init();
  runApp(AppCoordinator().start());
}

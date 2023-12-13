import 'package:flutter/material.dart';
import 'package:wallet/scenes/app/app.coordinator.dart';
import 'package:wallet/helper/local_notification.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocalNotification.setup();
  runApp(AppCoordinator().start());
}

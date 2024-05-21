import 'package:flutter/material.dart';
import 'package:wallet/components/page_route.dart';
import 'package:wallet/managers/manager.factory.dart';
import 'package:wallet/scenes/core/view.navigator.dart';

abstract class Coordinator implements ViewNavigator {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  // create base class for manager and implement it
  // create a list of managers. reflection by class name. T etc

  ManagerFactory get serviceManager {
    return ManagerFactory();
  }

  Coordinator();

  Widget start();

  void end();

  List<Widget> starts() {
    throw UnimplementedError();
  }

  void showInBottomSheet(Widget view) {
    Future.delayed(Duration.zero, () {
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(Coordinator.navigatorKey.currentContext!)
                .size
                .width,
            maxHeight: MediaQuery.of(Coordinator.navigatorKey.currentContext!)
                    .size
                    .height -
                60,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          isScrollControlled: true,
          context: Coordinator.navigatorKey.currentContext!,
          builder: (context) {
            return view;
          });
    });
  }

  void pushReplacement(Widget view, {bool fullscreenDialog = false}) {
    Future.delayed(Duration.zero, () {
      Coordinator.navigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
            settings: RouteSettings(name: view.key.toString()),
            builder: (context) {
              return view;
            },
            fullscreenDialog: fullscreenDialog),
      );
    });
  }

  void push(Widget view, {bool fullscreenDialog = false}) {
    Future.delayed(Duration.zero, () {
      Coordinator.navigatorKey.currentState?.push(
        MaterialPageRoute(
            settings: RouteSettings(name: view.key.toString()),
            builder: (context) {
              return view;
            },
            fullscreenDialog: fullscreenDialog),
      );
    });
  }

  void pop() {
    Coordinator.navigatorKey.currentState?.pop();
  }

  void pushCustom(Widget view, {bool fullscreenDialog = false}) {
    Future.delayed(Duration.zero, () {
      Coordinator.navigatorKey.currentState?.push(
          CustomPageRoute(page: view, fullscreenDialog: fullscreenDialog));
    });
  }

  void pushReplacementCustom(Widget view, {bool fullscreenDialog = false}) {
    Future.delayed(Duration.zero, () {
      Coordinator.navigatorKey.currentState?.pushReplacement(
          CustomPageRoute(page: view, fullscreenDialog: fullscreenDialog));
    });
  }

  void showDialog1(Widget view) {
    if (Coordinator.navigatorKey.currentContext == null) {
      return;
    }
    showDialog(
      context: Coordinator.navigatorKey.currentContext!,
      builder: (context) => view,
      barrierDismissible: false,
    );
  }
}

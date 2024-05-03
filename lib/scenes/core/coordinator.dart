import 'package:flutter/material.dart';
import 'package:wallet/components/page_route.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigator.dart';

abstract class Coordinator implements ViewNavigator {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Coordinator();

  ViewBase start();

  void end();

  List<ViewBase> starts() {
    throw UnimplementedError();
  }

  void showInBottomSheet(ViewBase view) {
    Future.delayed(Duration.zero, () {
      showModalBottomSheet(
          backgroundColor: Colors.transparent,
          constraints:
              BoxConstraints(
                minWidth:
                    MediaQuery.of(Coordinator.navigatorKey.currentContext!)
                        .size
                        .width,
                maxHeight:
                    MediaQuery.of(Coordinator.navigatorKey.currentContext!)
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

  void pushReplacement(ViewBase view, {bool fullscreenDialog = false}) {
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

  void push(ViewBase view, {bool fullscreenDialog = false}) {
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

  void pushCustom(ViewBase view, {bool fullscreenDialog = false}) {
    Future.delayed(Duration.zero, () {
      Coordinator.navigatorKey.currentState?.push(
          CustomPageRoute(page: view, fullscreenDialog: fullscreenDialog));
    });
  }

  void pushReplacementCustom(ViewBase view, {bool fullscreenDialog = false}) {
    Future.delayed(Duration.zero, () {
      Coordinator.navigatorKey.currentState?.pushReplacement(
          CustomPageRoute(page: view, fullscreenDialog: fullscreenDialog));
    });
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/managers/manager.factory.dart';
import 'package:wallet/scenes/components/page_route.dart';
import 'package:wallet/scenes/core/responsive.dart';
import 'package:wallet/scenes/core/view.navigator.dart';

abstract class Coordinator implements ViewNavigator {
  // root navigator key used for app level
  static GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: "RootNavigatorKey");

  // nested navigator key. used on sub navigation view.
  static GlobalKey<NavigatorState>? nestedNavigatorKey;

  // get current navigator key
  GlobalKey<NavigatorState> get navigatorKey {
    return nestedNavigatorKey ?? Coordinator.rootNavigatorKey;
  }

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

  void showInBottomSheet(
    Widget view, {
    Color? backgroundColor,
  }) {
    Future.delayed(Duration.zero, () {
      if (Responsive.isMobile(Coordinator.rootNavigatorKey.currentContext!)) {
        _showMobileBottomSheet(
          view,
          backgroundColor: backgroundColor,
        );
      } else {
        // desktop and tablet
        _showDesktopBottomSheet(
          view,
          backgroundColor: backgroundColor,
        );
      }
    });
  }

  void _showMobileBottomSheet(
    Widget view, {
    Color? backgroundColor,
  }) {
    final BuildContext context = Coordinator.rootNavigatorKey.currentContext!;
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height - 60,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        isScrollControlled: true,
        builder: (context) {
          return view;
        });
  }

  void _showDesktopBottomSheet(
    Widget view, {
    Color? backgroundColor,
  }) {
    final BuildContext context = Coordinator.rootNavigatorKey.currentContext!;
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        constraints: BoxConstraints(
          maxWidth:
              max(maxDeskTopSheetWidth, MediaQuery.of(context).size.width / 3),
          maxHeight: MediaQuery.of(context).size.height,
          minHeight: MediaQuery.of(context).size.height,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
        builder: (BuildContext context) {
          return Align(
              child: Container(
                  decoration: BoxDecoration(
                    color: backgroundColor ?? ProtonColors.backgroundProton,
                    borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 30),
                  padding: const EdgeInsets.all(10),
                  child: view));
        });
  }

  void pushReplacement(Widget view, {bool fullscreenDialog = false}) {
    Future.delayed(Duration.zero, () {
      Coordinator.rootNavigatorKey.currentState?.pushReplacement(
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
      navigatorKey.currentState?.push(
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
    Coordinator.rootNavigatorKey.currentState?.pop();
  }

  void pushCustom(Widget view, {bool fullscreenDialog = false}) {
    Future.delayed(Duration.zero, () {
      Coordinator.rootNavigatorKey.currentState?.push(
          CustomPageRoute(page: view, fullscreenDialog: fullscreenDialog));
    });
  }

  void pushReplacementCustom(Widget view, {bool fullscreenDialog = false}) {
    Future.delayed(Duration.zero, () {
      Coordinator.rootNavigatorKey.currentState?.pushReplacement(
          CustomPageRoute(page: view, fullscreenDialog: fullscreenDialog));
    });
  }

  void showDialog1(Widget view) {
    if (Coordinator.rootNavigatorKey.currentContext == null) {
      return;
    }
    showDialog(
      context: Coordinator.rootNavigatorKey.currentContext!,
      builder: (context) => view,
      barrierDismissible: false,
    );
  }
}

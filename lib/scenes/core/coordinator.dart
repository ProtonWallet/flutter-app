import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/helper/extension/build.context.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/manager.factory.dart';
import 'package:wallet/scenes/components/page_route.dart';
import 'package:wallet/scenes/core/responsive.dart';
import 'package:wallet/scenes/core/view.navigator.dart';

abstract class Coordinator implements ViewNavigator {
  // root navigator key used for app level
  static final rootNavigatorKey = GlobalKey<NavigatorState>(
    debugLabel: "RootNavigatorKey",
  );

  // nested navigator key. used on sub navigation view.
  static GlobalKey<NavigatorState>? nestedNavigatorKey;

  // get current navigator key
  GlobalKey<NavigatorState> get navigatorKey {
    return nestedNavigatorKey ?? Coordinator.rootNavigatorKey;
  }

  // create base class for manager and implement it
  // create a list of managers. reflection by class name. T etc
  @protected
  ManagerFactory get serviceManager {
    return ManagerFactory();
  }

  Coordinator();

  Widget start();

  void end();

  List<Widget> starts() {
    throw UnimplementedError();
  }

  Future<bool> showInBottomSheet(
    Widget view, {
    Color? backgroundColor,
    bool fullScreen = false,
    bool enableDrag = true,
    bool isDismissible = true,
    bool canPop = true,
  }) async {
    await Future.delayed(Duration.zero);
    final bool result;
    if (Responsive.isMobile(Coordinator.rootNavigatorKey.currentContext!)) {
      result = await _showMobileBottomSheet(
        view,
        enableDrag,
        isDismissible: isDismissible,
        backgroundColor: backgroundColor,
        fullScreen: fullScreen,
        canPop: canPop,
      );
    } else {
      // desktop and tablet
      result = await _showDesktopBottomSheet(
        view,
        enableDrag,
        isDismissible: isDismissible,
        backgroundColor: backgroundColor,
        canPop: canPop,
      );
    }
    return result;
  }

  Future<bool> _showMobileBottomSheet(
    Widget view,
    bool enableDrag, {
    Color? backgroundColor,
    bool fullScreen = false,
    bool isDismissible = true,
    bool canPop = true,
  }) async {
    final context = Coordinator.rootNavigatorKey.currentContext!;
    final result = await showModalBottomSheet<bool>(
      context: context,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        minWidth: context.width,
        maxHeight: fullScreen ? double.infinity : context.height - 60,
      ),
      isScrollControlled: true,
      builder: (context) {
        return PopScope(canPop: canPop, child: view);
      },
    );
    logger.i("Bottom sheet closed with result: ${result ?? false}");
    return result ?? false;
  }

  Future<bool> _showDesktopBottomSheet(
    Widget view,
    bool enableDrag, {
    Color? backgroundColor,
    bool isDismissible = true,
    bool canPop = true,
  }) async {
    final context = Coordinator.rootNavigatorKey.currentContext!;
    final result = await showModalBottomSheet<bool>(
      context: context,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: canPop
            ? max(maxDeskTopSheetWidth, context.width / 3)
            : double.infinity,
        minHeight: context.height,
      ),
      builder: (BuildContext context) {
        return PopScope(
          canPop: canPop,
          child: Align(
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor ?? ProtonColors.backgroundNorm,
                borderRadius:
                    BorderRadius.all(Radius.circular(canPop ? 24.0 : 0)),
              ),
              margin: EdgeInsets.symmetric(vertical: canPop ? 30 : 0),
              padding: const EdgeInsets.all(10),
              child: view,
            ),
          ),
        );
      },
    );
    logger.i("Desktop bottom sheet closed with result: ${result ?? false}");
    return result ?? false;
  }

  void pushReplacement(Widget view, {bool fullscreenDialog = false}) {
    Future.delayed(Duration.zero, () {
      Coordinator.rootNavigatorKey.currentState?.pushReplacement(
        MaterialPageRoute(
          settings: RouteSettings(name: view.key.toString()),
          builder: (context) {
            return view;
          },
          fullscreenDialog: fullscreenDialog,
        ),
      );
    });
  }

  /// use it carefully. this will remove all Widgets only keep the input view.
  ///  this used only login to clean up all unreleased views.
  void pushReplacementRemoveAll(Widget view, {bool fullscreenDialog = false}) {
    rootNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(
        settings: RouteSettings(name: view.key.toString()),
        builder: (context) {
          return view;
        },
        fullscreenDialog: fullscreenDialog,
      ),
      (Route<dynamic> route) => false, // Keep only the current route
    );
  }

  void push(Widget view, {bool fullscreenDialog = false}) {
    Future.delayed(Duration.zero, () {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          settings: RouteSettings(name: view.key.toString()),
          builder: (context) {
            return view;
          },
          fullscreenDialog: fullscreenDialog,
        ),
      );
    });
  }

  void pop() {
    Coordinator.rootNavigatorKey.currentState?.pop();
  }

  void pushCustom(Widget view, {bool fullscreenDialog = false}) {
    Future.delayed(Duration.zero, () {
      Coordinator.rootNavigatorKey.currentState?.push(CustomPageRoute(
        page: view,
        fullscreenDialog: fullscreenDialog,
      ));
    });
  }

  void pushReplacementCustom(Widget view, {bool fullscreenDialog = false}) {
    Future.delayed(Duration.zero, () {
      Coordinator.rootNavigatorKey.currentState?.pushReplacement(
        CustomPageRoute(page: view, fullscreenDialog: fullscreenDialog),
      );
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

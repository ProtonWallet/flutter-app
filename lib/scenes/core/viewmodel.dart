import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/helper/extension/platform.extension.dart';

abstract class ViewModel<T extends Coordinator>
    extends NavigationFlowInterface {
  GlobalKey<NavigatorState>? get nestedNavigatorKey => coordinator.navigatorKey;

  ViewModel(this.coordinator);
  final T coordinator;
  Stream<ViewModel> get datasourceChanged;
  void dispose() {
    coordinator.end();
  }

  Future<void> loadData();

  ViewSize? currentSize;

  bool get keepAlive => false;
  bool get mobile => PlatformExtension.mobile;
  bool get desktop => PlatformExtension.desktop;
  bool get screenSizeState => false;
}

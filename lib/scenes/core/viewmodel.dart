import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wallet/helper/extension/platform.extension.dart' as pf_ext;
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';

abstract class ViewModel<T extends Coordinator>
    extends NavigationFlowInterface {
  GlobalKey<NavigatorState>? get nestedNavigatorKey => coordinator.navigatorKey;

  ViewModel(this.coordinator);

  /// coordinator
  @protected
  @visibleForTesting
  final T coordinator;

  /// [ViewModel] stream controller
  final _dataChangedStream = StreamController<ViewModel>.broadcast();

  @protected
  void sinkAddSafe() {
    _dataChangedStream.sinkAddSafe(this);
  }

  /// steam and data changes state this will be listened from view
  ///   and call SetState when data changes.
  Stream<ViewModel> get datasourceChanged => _dataChangedStream.stream;

  Future<void> loadData();

  /// dispose function. all override ViewModel should call super.dispose()
  @mustCallSuper
  void dispose() {
    _dataChangedStream.close();
    coordinator.end();
  }

  ///
  ViewSize? currentSize;

  bool get isMobileSize => currentSize == ViewSize.mobile;

  bool get keepAlive => false;
  bool get mobile => pf_ext.mobile;
  bool get desktop => pf_ext.desktop;
  bool get screenSizeState => false;
}

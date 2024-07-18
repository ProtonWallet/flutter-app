import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/logs/logs.coordinator.dart';

abstract class LogsViewModel extends ViewModel<LogsCoordinator> {
  LogsViewModel(super.coordinator);

  String logs = "";

  void shareLogs();
  void clearLogs();
  final ScrollController scrollController = ScrollController();
}

class LogsViewModelImpl extends LogsViewModel {
  LogsViewModelImpl(
    super.coordinator,
  );

  bool hadLocallogin = false;

  @override
  Future<void> loadData() async {
    await loadLogs();

    sinkAddSafe();

    // Scroll to the bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      default:
        break;
    }
  }

  Future<void> loadLogs() async {
    final directory = await getApplicationDocumentsDirectory();
    final logFile = File('${directory.path}/logs/app.log');
    if (logFile.existsSync()) {
      final logs = await logFile.readAsString();
      this.logs = logs;
    }
  }

  @override
  void shareLogs() {
    Share.share(logs);
  }

  @override
  Future<void> clearLogs() async {
    await LoggerService.reset();
    loadLogs();
    sinkAddSafe();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    });
  }
}

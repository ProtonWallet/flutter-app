import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
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

  List<FileSystemEntity> files = [];
  late Directory folderDir;

  Future<void> shareFile(File file);

  Future<void> downloadFile(String fileName, String downloadUrl);

  Future<void> deleteFile(File file);
}

class LogsViewModelImpl extends LogsViewModel {
  LogsViewModelImpl(
    super.coordinator,
  );

  bool hadLocallogin = false;

  @override
  Future<void> loadData() async {
    // await loadLogs();
    await _loadFiles();

    sinkAddSafe();
  }

  Future<void> _loadFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final logsPath = join(directory.path, "logs");
    // Initialize directory
    folderDir = Directory(logsPath);
    if (folderDir.existsSync()) {
      files = folderDir.listSync().whereType<File>().toList();
      files = files
          .where((e) =>
              e.path.endsWith("app.log") | e.path.endsWith("app_rust_logs.txt"))
          .toList();
    } else {
      logger.i("Folder does not exist.");
    }
    sinkAddSafe();
  }

  @override
  Future<void> downloadFile(String fileName, String downloadUrl) async {
    try {
      final savePath = '${folderDir.path}/$fileName';
      final Dio dio = Dio();
      await dio.download(downloadUrl, savePath);
      _loadFiles(); // Reload files after download
    } catch (e) {
      logger.e('Download error: $e');
    }
  }

  @override
  Future<void> deleteFile(File file) async {
    try {
      await file.delete();
      _loadFiles(); // Reload files after deletion
    } catch (e) {
      logger.e('Delete error: $e');
    }
  }

  @override
  Future<void> shareFile(File file) async {
    try {
      final xFile = XFile(file.path);
      await Share.shareXFiles([xFile]);
    } catch (e) {
      logger.e('Error sharing file: $e');
    }
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

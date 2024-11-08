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

  final ScrollController scrollController = ScrollController();

  List<FileSystemEntity> files = [];
  late Directory folderDir;

  Future<void> shareFile(File file);

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
      files = folderDir
          .listSync()
          .whereType<File>()
          .where((e) => e.path.endsWith(".log"))
          .toList();

      final timestampPattern = RegExp(r'(app_logs_|app_rust_logs_)(\d{14})');

      // Sort files by extracted timestamp
      files.sort((a, b) {
        final timestampA = _extractTimestamp(a.path, timestampPattern);
        final timestampB = _extractTimestamp(b.path, timestampPattern);
        return timestampA.compareTo(timestampB) * -1;
      });
    } else {
      logger.i("Folder does not exist.");
    }
    sinkAddSafe();
  }

  // Extracts the timestamp from the filename and converts it to DateTime
  DateTime _extractTimestamp(String filePath, RegExp pattern) {
    final match = pattern.firstMatch(filePath);
    if (match != null && match.group(2) != null) {
      final timestampStr = match.group(2)!;
      // Parse the timestamp string as DateTime
      return DateTime.parse('${timestampStr.substring(0, 4)}'
          '-${timestampStr.substring(4, 6)}'
          '-${timestampStr.substring(6, 8)}'
          'T${timestampStr.substring(8, 10)}'
          ':${timestampStr.substring(10, 12)}'
          ':${timestampStr.substring(12, 14)}');
    }
    // Return a default DateTime far in the past if parsing fails
    return DateTime(3000);
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
}

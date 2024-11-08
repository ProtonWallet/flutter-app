import 'dart:io';
import 'dart:math';

import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallet/rust/api/flutter_logger.dart' as frb_logger;
import 'package:wallet/rust/api/logger.dart' as rust_logger;

var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
  output: MultiOutput([
    ConsoleOutput(),
  ]),
);

/// Rules:
///   mobile  10mb /logfile.  100mb max
///   desktop 30mb / logfile 300mb max
class LoggerService {
  LoggerService();

  static String appLogName = "app_logs.log";
  static String rustLogName = "app_rust_logs.log";

  static String customFileNameFormatter(DateTime timestamp) {
    final formattedTimestamp = DateFormat('yyyyMMddHHmmss').format(timestamp);
    return 'app_logs_$formattedTimestamp.log';
  }

  static Future<void> initDartLogger() async {
    final directory = await getApplicationDocumentsDirectory();
    final logsPath = join(directory.path, "logs");
    logger = Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        AdvancedFileOutput(
          path: logsPath,
          maxFileSizeKB: 10240,
          latestFileName: appLogName,
          fileNameFormatter: customFileNameFormatter,
        )
      ]),
    );
  }

  static Future<void> initRustLogger() async {
    /// if enable rust_logger then we need to disable frb_logger
    final directory = await getApplicationDocumentsDirectory();
    final logsDir = join(directory.path, "logs");
    rust_logger.initRustLogging(
      filePath: logsDir,
      fileName: 'app_rust_logs.log',
    );
  }

  static Future<void> setupFrbLogger() async {
    frb_logger.infoLogger().listen((msg) {
      switch (msg.logLevel) {
        case frb_logger.Level.error:
          logger.e("${msg.lbl.padRight(8)}: ${msg.msg}");
        case frb_logger.Level.warn:
          logger.w("${msg.lbl.padRight(8)}: ${msg.msg}");
        case frb_logger.Level.info:
          logger.i("${msg.lbl.padRight(8)}: ${msg.msg}");
        case frb_logger.Level.debug:
          logger.d("${msg.lbl.padRight(8)}: ${msg.msg}");
        case frb_logger.Level.trace:
          logger.t("${msg.lbl.padRight(8)}: ${msg.msg}");
      }
    });
  }

  static Future<String> getLogsSize() async {
    int totalSize = 0;
    final directory = await getApplicationDocumentsDirectory();
    final logsPath = join(directory.path, "logs");
    final folder = Directory(logsPath);
    // Use recursive iteration to get all file sizes
    if (folder.existsSync()) {
      await for (FileSystemEntity entity in folder.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
    }
    return _formatBytes(totalSize);
  }

  /// Function to format bytes into a human-readable string
  static String _formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    final size = bytes / pow(1024, i);
    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static Future<void> clearLogs() async {
    final exceptFiles = [appLogName, rustLogName];
    final directory = await getApplicationDocumentsDirectory();
    final logsPath = join(directory.path, "logs");
    final folder = Directory(logsPath);

    if (folder.existsSync()) {
      final files = folder.listSync();

      for (final file in files) {
        if (file is File && !exceptFiles.contains(file.path.split('/').last)) {
          try {
            await file.delete();
            logger.i('${file.path} deleted');
          } catch (e) {
            logger.i('Error deleting ${file.path}: $e');
          }
        }
      }
      logger.i('Folder cleared except for ${exceptFiles.join(", ")}');
    } else {
      logger.i('Directory does not exist');
    }
  }
}

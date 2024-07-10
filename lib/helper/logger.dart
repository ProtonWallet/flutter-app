import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

var logger = Logger(
  printer: PrettyPrinter(
    methodCount: 1,
    errorMethodCount: 8,
    lineLength: 120,
    colors: true,
    printEmojis: true,
    printTime: true,
    noBoxingByDefault: false,
  ),
  output: MultiOutput([
    ConsoleOutput(),
  ]),
);

class LoggerService {
  LoggerService();

  static Future<void> initLogFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final logsPath = join(directory.path, "logs");
    logger = Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
        noBoxingByDefault: false,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        AdvancedFileOutput(
          path: logsPath,
          maxFileSizeKB: 5120,
          latestFileName: "app.log",
        )
      ]),
    );
  }

  static Future<void> reset() async {
    final directory = await getApplicationDocumentsDirectory();
    final logsPath = join(directory.path, "logs");

    final logFile = File('$logsPath/app.log');
    if (await logFile.exists()) {
      await logFile.delete();
    }
    logger = Logger(
      printer: PrettyPrinter(
        methodCount: 1,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: true,
        noBoxingByDefault: false,
      ),
      output: MultiOutput([
        ConsoleOutput(),
        AdvancedFileOutput(
          path: logsPath,
          maxFileSizeKB: 5120,
          latestFileName: "app.log",
        )
      ]),
    );
  }
}

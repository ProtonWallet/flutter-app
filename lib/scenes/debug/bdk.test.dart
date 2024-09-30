import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/helper/logger.dart';

class BdkLibrary {
  Future<void> clearLocalCache() async {
    String? path;
    if (Platform.isWindows || Platform.isLinux) {
      final appDocumentsDir = await getApplicationDocumentsDirectory();
      path = join(appDocumentsDir.path, "databases");
    } else {
      path = await getDatabasesPath();
      if (!path.contains("databases")) {
        path = join(path, "databases");
      }
    }

    final dir = Directory(path);
    if (dir.existsSync()) {
      final List<FileSystemEntity> entities = dir.listSync();
      for (FileSystemEntity entity in entities) {
        if (entity is File) {
          final String fileName = basename(entity.path);
          bool delete = false;
          if (!delete && fileName.endsWith(".sqlite")) {
            delete = true;
          }
          if (!delete && fileName.endsWith("true.db")) {
            delete = true;
          }
          if (!delete && fileName.endsWith("false.db")) {
            delete = true;
          }
          if (!delete && fileName.contains("_m_")) {
            delete = true;
          }
          if (delete) {
            logger.i("removing bdk db: ${entity.path}");
            entity.deleteSync();
          }
        }
      }
    }
  }
}

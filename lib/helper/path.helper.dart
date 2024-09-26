import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<Directory> _getDatabaseFolder() async {
  const dbFolder = "databases";
  final appDocumentsDir = await getApplicationDocumentsDirectory();
  final folderPath = Directory(p.join(appDocumentsDir.path, dbFolder));

  if (!folderPath.existsSync()) {
    await folderPath.create(recursive: true);
  }
  return folderPath;
}

Future<String> getDatabaseFolderPath() async {
  final folder = await _getDatabaseFolder();
  return folder.path;
}

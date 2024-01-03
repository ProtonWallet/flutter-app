import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/models/wallet.dao.impl.dart';

import '../models/account.dao.impl.dart';

class DBHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await init();
    return _database!;
  }

  static Future<Database> init() async {
    late Database db;
    if (Platform.isWindows) {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      String path =
          join(appDocumentsDir.path, "databases", "native_database.db");
      db = await databaseFactory.openDatabase(
        path,
      );
    } else {
      var path = await getDatabasesPath();
      db = await (openDatabase(join(path, "databases", "native_database.db")));
    }
    WalletDaoImpl(db).initTable();
    AccountDaoImpl(db).initTable();

    return db;
  }
}

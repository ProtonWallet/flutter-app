import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/models/database/app.database.dart';

class DBHelper {
  static AppDatabase? _appDatabase;

  static Future<Database> get database async {
    if (_appDatabase != null) {
      return _appDatabase!.db;
    }

    init();
    return _appDatabase!.db;
  }

  static Future<void> init() async {
    _appDatabase = AppDatabase();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int appDatabaseVersion = preferences.getInt("appDatabaseVersion") ?? 1;
    await _appDatabase!.buildDatabase(oldVersion: appDatabaseVersion);
    preferences.setInt("appDatabaseVersion", _appDatabase!.VERSION);
  }
}

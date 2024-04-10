import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/database/base.database.dart';
import 'package:wallet/models/database/database.migration.dart';

abstract class AddressDatabase extends BaseDatabase {
  static DatabaseMigration migration_0 = DatabaseMigration((Database db) async {
    await db.execute('''
        CREATE TABLE IF NOT EXISTS `address` (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          serverID TEXT,
          email TEXT,
          serverWalletID TEXT,
          serverAccountID TEXT
        )
    ''');
  });

  static void Function(Database db) dropTables = (Database db) {
    db.execute('''
      DROP TABLE IF EXISTS `address`
    ''');
  };
}

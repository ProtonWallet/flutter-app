import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/database/base.database.dart';
import 'package:wallet/models/database/database.migration.dart';

abstract class AccountDatabase extends BaseDatabase {
  static DatabaseMigration migration_0 = DatabaseMigration((Database db) async {
    await db.execute('''
        CREATE TABLE IF NOT EXISTS `account` (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          walletID INTEGER,
          derivationPath TEXT,
          label BLOB,
          scriptType INTEGER,
          createTime INTEGER,
          modifyTime INTEGER,
          UNIQUE (walletID, derivationPath)
        )
    ''');
  });

  static void Function(Database db) dropTables = (Database db) {
    db.execute('''
      DROP TABLE IF EXISTS `account`
    ''');
  };
}

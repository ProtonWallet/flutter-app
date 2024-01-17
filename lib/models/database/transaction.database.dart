import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/database/base.database.dart';
import 'package:wallet/models/database/database.migration.dart';

abstract class TransactionDatabase extends BaseDatabase {
  static DatabaseMigration migration_0 = DatabaseMigration((Database db) async {
    await db.execute('''
        CREATE TABLE IF NOT EXISTS `walletTransaction` (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          walletID INTEGER,
          label BLOB,
          externalTransactionID BLOB,
          createTime INTEGER,
          modifyTime INTEGER
        )
    ''');
  });

  static void Function(Database db) dropTables = (Database db) {
    db.execute('''
      DROP TABLE IF EXISTS `walletTransaction`
    ''');
  };
}

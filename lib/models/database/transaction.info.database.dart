import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/database/base.database.dart';
import 'package:wallet/models/database/database.migration.dart';

abstract class TransactionInfoDatabase extends BaseDatabase {
  static DatabaseMigration migration_0 = DatabaseMigration((Database db) async {
    await db.execute('''
        CREATE TABLE IF NOT EXISTS `transactionInfo` (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          externalTransactionID BLOB,
          amountInSATS INTEGER,
          feeInSATS INTEGER,
          isSend INTEGER,
          transactionTime INTEGER,
          feeMode INTEGER
        )
    ''');
  });

  static DatabaseMigration migration_1 = DatabaseMigration((Database db) async {
    await db.execute('ALTER TABLE transactionInfo ADD COLUMN serverWalletID TEXT;');
    await db.execute('ALTER TABLE transactionInfo ADD COLUMN serverAccountID TEXT;');
  });

  static void Function(Database db) dropTables = (Database db) {
    db.execute('''
      DROP TABLE IF EXISTS `transactionInfo`
    ''');
  };
}

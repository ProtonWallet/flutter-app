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

  static DatabaseMigration migration_1 = DatabaseMigration((Database db) async {
    await db.execute('''
        ALTER TABLE walletTransaction ADD COLUMN hashedTransactionID BLOB;
        ALTER TABLE walletTransaction ADD COLUMN transactionID TEXT;
        ALTER TABLE walletTransaction ADD COLUMN transactionTime TEXT null;
        ALTER TABLE walletTransaction ADD COLUMN exchangeRateID TEXT null;
        ALTER TABLE walletTransaction ADD COLUMN serverWalletID TEXT;
        ALTER TABLE walletTransaction ADD COLUMN serverAccountID TEXT;
    ''');
  });

  static DatabaseMigration migration_2 = DatabaseMigration((Database db) async {
    await db.execute('''
        ALTER TABLE walletTransaction ADD COLUMN sender TEXT null;
        ALTER TABLE walletTransaction ADD COLUMN tolist TEXT null;
        ALTER TABLE walletTransaction ADD COLUMN subject TEXT null;
        ALTER TABLE walletTransaction ADD COLUMN body TEXT null;
    ''');
  });

  static void Function(Database db) dropTables = (Database db) {
    db.execute('''
      DROP TABLE IF EXISTS `walletTransaction`
    ''');
  };
}

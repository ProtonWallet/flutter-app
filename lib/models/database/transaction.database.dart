import 'package:wallet/models/database/base.database.dart';

class TransactionDatabase extends BaseDatabase {
  TransactionDatabase(super.db, super.tableName);

  @override
  Future<void> migration_0() async {
    await createTable('''
        CREATE TABLE IF NOT EXISTS `walletTransaction` (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          walletID INTEGER,
          label BLOB,
          externalTransactionID BLOB,
          createTime INTEGER,
          modifyTime INTEGER
        )
    ''');
  }

  Future<void> migration_1() async {
    await addColumn('hashedTransactionID', 'BLOB');
    await addColumn('transactionID', 'TEXT');
    await addColumn('transactionTime', 'BLTEXT NULL');
    await addColumn('exchangeRateID', 'TEXT NULL');
    await addColumn('serverWalletID', 'TEXT');
    await addColumn('serverAccountID', 'TEXT');
  }

  Future<void> migration_2() async {
    await addColumn('sender', 'TEXT NULL');
    await addColumn('tolist', 'TEXT NULL');
    await addColumn('subject', 'TEXT NULL');
    await addColumn('body', 'TEXT NULL');
  }

  Future<void> migration_3() async {
    await addColumn('serverID', 'TEXT');
  }

  Future<void> migration_4() async {
    await addColumn('type', 'INTEGER');
  }
}

import 'dart:async';

import 'package:wallet/models/database/base.database.dart';

class WalletDatabase extends BaseDatabase {
  WalletDatabase(super.db, super.tableName);

  @override
  Future<void> migration_0() async {
    await dropTable();
    await createTable('''
        CREATE TABLE IF NOT EXISTS `$tableName` (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userID TEXT,
          walletID TEXT,
          name TEXT,
          passphrase INTEGER,
          publicKey BLOB,
          imported INTEGER,
          priority INTEGER,
          status INTEGER,
          type INTEGER,
          createTime INTEGER,
          modifyTime INTEGER,
          fingerprint TEXT,
          showWalletRecovery INTEGER NULL,
          UNIQUE (userID, walletID)
        )
    ''');
    await addIndex("userID");
    await addIndex("walletID");
  }

  Future<void> migration_1() async {
    await addColumn('migrationRequired', ' INTEGER NULL');
  }
}

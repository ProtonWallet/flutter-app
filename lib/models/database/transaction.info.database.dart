import 'dart:async';

import 'package:wallet/models/database/base.database.dart';

class TransactionInfoDatabase extends BaseDatabase {
  @override
  Future<void> migration_0() async {
    await createTable('''
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
  }

  Future<void> migration_1() async {
    await addColumn('serverWalletID', 'TEXT');
    await addColumn('serverAccountID', 'TEXT');
  }

  Future<void> migration_2() async {
    await addColumn('toEmail', 'TEXT');
    await addColumn('toBitcoinAddress', 'TEXT');
  }

  TransactionInfoDatabase(super.db, super.tableName);
}

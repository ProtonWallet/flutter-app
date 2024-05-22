import 'package:wallet/models/database/base.database.dart';

class AccountDatabase extends BaseDatabase {
  AccountDatabase(super.db, super.tableName);
  @override
  Future<void> migration_0() {
    return createTable('''
      CREATE TABLE IF NOT EXISTS `account` (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        walletID INTEGER,
        derivationPath TEXT,
        label BLOB,
        scriptType INTEGER,
        createTime INTEGER,
        modifyTime INTEGER,
        serverAccountID TEXT,
        UNIQUE (walletID, derivationPath)
      )
    ''');
  }
  Future<void> migration_1() {
    // Add column `fingerprint`
    return addColumn("fiatCurrency", "TEXT");
  }
}

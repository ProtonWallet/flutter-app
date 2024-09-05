import 'package:wallet/models/database/base.database.dart';

class AccountDatabase extends BaseDatabase {
  AccountDatabase(super.db, super.tableName);
  @override
  Future<void> migration_0() async {
    await dropTable();
    await createTable('''
      CREATE TABLE IF NOT EXISTS `$tableName` (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        accountID TEXT,
        walletID TEXT,
        derivationPath TEXT,
        label BLOB,
        scriptType INTEGER,
        createTime INTEGER,
        modifyTime INTEGER,
        fiatCurrency TEXT,
        priority INTEGER,
        lastUsedIndex INTEGER,
        poolSize INTEGER DEFAULT 10,
        UNIQUE (walletID, derivationPath)
      )
    ''');
    await addIndex("walletID");
    await addIndex("accountID");
  }
}

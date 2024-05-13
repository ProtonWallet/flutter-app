import 'package:wallet/models/database/base.database.dart';

class AddressDatabase extends BaseDatabase {
  @override
  Future<void> migration_0() {
    return createTable('''
        CREATE TABLE IF NOT EXISTS `address` (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          serverID TEXT,
          email TEXT,
          serverWalletID TEXT,
          serverAccountID TEXT
        )
    ''');
  }

  AddressDatabase(super.db, super.tableName);
}

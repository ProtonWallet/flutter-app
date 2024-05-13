import 'package:wallet/models/database/base.database.dart';

class BitcoinAddressDatabase extends BaseDatabase {
  @override
  Future<void> migration_0() {
    return createTable('''
        CREATE TABLE IF NOT EXISTS `bitcoinAddress` (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          walletID INTEGER,
          accountID INTEGER,
          bitcoinAddress TEXT,
          bitcoinAddressIndex INTEGER,
          inEmailIntegrationPool INTEGER,
          used INTEGER
        )
    ''');
  }

  BitcoinAddressDatabase(super.db, super.tableName);
}

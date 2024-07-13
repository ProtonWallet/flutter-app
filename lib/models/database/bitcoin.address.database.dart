import 'package:wallet/models/database/base.database.dart';

class BitcoinAddressDatabase extends BaseDatabase {
  @override
  Future<void> migration_0() async {
    await createTable('''
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

  Future<void> migration_1() async {
    // Add column `fingerprint`
    await addColumn("serverWalletID", "TEXT");
    await addColumn("serverAccountID", "TEXT");
  }

  BitcoinAddressDatabase(super.db, super.tableName);
}

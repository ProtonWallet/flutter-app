import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/database/base.database.dart';
import 'package:wallet/models/database/database.migration.dart';

abstract class BitcoinAddressDatabase extends BaseDatabase {
  static DatabaseMigration migration_0 = DatabaseMigration((Database db) async {
    await db.execute('''
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
  });

  static void Function(Database db) dropTables = (Database db) {
    db.execute('''
      DROP TABLE IF EXISTS `bitcoinAddress`
    ''');
  };
}

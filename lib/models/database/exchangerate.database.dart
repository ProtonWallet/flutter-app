import 'package:wallet/models/database/base.database.dart';

class ExchangeRateDatabase extends BaseDatabase {
  @override
  Future<void> migration_0() async {
    await createTable('''
        CREATE TABLE IF NOT EXISTS `exchangeRate` (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          serverID TEXT,
          bitcoinUnit TEXT,
          fiatCurrency TEXT,
          sign TEXT,
          exchangeRateTime TEXT,
          exchangeRate INTEGER,
          cents INTEGER
        )
    ''');
  }

  ExchangeRateDatabase(super.db, super.tableName);
}

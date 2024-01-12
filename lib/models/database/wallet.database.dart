import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/database/base.database.dart';
import 'package:wallet/models/database/database.migration.dart';

abstract class WalletDatabase extends BaseDatabase {
  static DatabaseMigration MIGRATION_0 = DatabaseMigration((Database db) async {
    await db.execute('''
        CREATE TABLE IF NOT EXISTS wallet (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userID INTEGER,
          name TEXT,
          mnemonic BLOB,
          passphrase INTEGER,
          publicKey BLOB,
          imported INTEGER,
          priority INTEGER,
          status INTEGER,
          type INTEGER,
          createTime INTEGER,
          modifyTime INTEGER,
          localDBName TEXT
        )
    ''');
  });
}
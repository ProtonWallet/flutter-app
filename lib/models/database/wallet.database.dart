import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/database/base.database.dart';
import 'package:wallet/models/database/database.migration.dart';

abstract class WalletDatabase extends BaseDatabase {
  static DatabaseMigration migration_0 = DatabaseMigration((Database db) async {
    await db.execute('''
        CREATE TABLE IF NOT EXISTS `wallet` (
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
          localDBName TEXT,
          serverWalletID TEXT
        )
    ''');
  });

  static DatabaseMigration migration_1 = DatabaseMigration((Database db) async {
    // Drop column `localDBName`
    await db.execute('''
        CREATE TABLE IF NOT EXISTS `tmp_wallet` (
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
          serverWalletID TEXT
        );
        
        INSERT INTO `tmp_wallet` 
        SELECT id, userID, name, mnemonic, passphrase, publicKey, imported, priority, status, type, createTime, modifyTime, serverWalletID
        FROM `wallet`;
        
        DROP TABLE wallet;
        
        ALTER TABLE tmp_wallet RENAME TO wallet;
    ''');
  });

  static void Function(Database db) dropTables = (Database db) {
    db.execute('''
      DROP TABLE IF EXISTS `wallet`
    ''');
  };
}

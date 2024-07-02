import 'dart:async';

import 'package:wallet/models/database/base.database.dart';

class WalletDatabase extends BaseDatabase {
  WalletDatabase(super.db, super.tableName);

  @override
  Future<void> migration_0() {
    return createTable('''
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
  }

  Future<void> migration_1() {
    // Drop column `localDBName`
    return createTable('''
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
  }

  Future<void> migration_2() {
    // Add column `fingerprint`
    return addColumn("fingerprint", "TEXT NULL");
  }

  Future<void> migration_3() {
    // Add column `showWalletRecovery` from walletSettings
    return addColumn("showWalletRecovery", "INTEGER NULL");
  }
}

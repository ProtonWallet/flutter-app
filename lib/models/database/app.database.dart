import 'dart:core';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/models/account.dao.impl.dart';
import 'package:wallet/models/bitcoin.address.dao.impl.dart';
import 'package:wallet/models/contacts.dao.impl.dart';
import 'package:wallet/models/address.dao.impl.dart';
import 'package:wallet/models/transaction.dao.impl.dart';
import 'package:wallet/models/transaction.info.dao.impl.dart';
import 'package:wallet/models/wallet.dao.impl.dart';

import 'migration.dart';
import 'migration.container.dart';

class AppDatabase {
  static String dbFolder = "databases";
  static String dbName = "proton_wallet_db";
  static String versionKey = "db_version";
  // current version of the database
  int version = 11;
  // future: if the database cached version < resetVersion. rebuild the cache with latest schema. we can clean up migrations.
  int resetVersion = 1;
  bool dbReset = false;

  late Database db;

  late MigrationContainer migrationContainer;
  late AccountDao accountDao;
  late WalletDao walletDao;
  late TransactionDao transactionDao;
  late ContactsDao contactsDao;
  late AddressDao addressDao;
  late BitcoinAddressDao bitcoinAddressDao;
  late TransactionInfoDao transactionInfoDao;

  AppDatabase() {
    migrationContainer = MigrationContainer();
  }

  Future<void> reset() async {
    await dropAllTables();
    await buildDatabase();
  }

  Future<void> dropAllTables() async {
    await walletDao.dropTable();
    await accountDao.dropTable();
    await transactionDao.dropTable();
    await contactsDao.dropTable();
    await addressDao.dropTable();
    await bitcoinAddressDao.dropTable();
    await transactionInfoDao.dropTable();
  }

  void initDAO() {
    walletDao = WalletDaoImpl(db);
    accountDao = AccountDaoImpl(db);
    transactionDao = TransactionDaoImpl(db);
    contactsDao = ContactsDaoImpl(db);
    addressDao = AddressDaoImpl(db);
    bitcoinAddressDao = BitcoinAddressDaoImpl(db);
    transactionInfoDao = TransactionInfoDaoImpl(db);
  }

  void buildMigration() {
    List<Migration> migrations = [
      Migration(1, 2, () async {
        await walletDao.migration_0();
        await accountDao.migration_0();
      }),
      Migration(2, 3, () async {
        await transactionDao.migration_0();
      }),
      Migration(3, 4, () async {
        await walletDao.migration_1();
      }),
      Migration(4, 5, () async {
        await walletDao.migration_2();
      }),
      Migration(5, 6, () async {
        await contactsDao.migration_0();
      }),
      Migration(6, 7, () async {
        await addressDao.migration_0();
      }),
      Migration(7, 8, () async {
        await transactionDao.migration_1();
      }),
      Migration(8, 9, () async {
        await transactionDao.migration_2();
      }),
      Migration(9, 10, () async {
        await transactionInfoDao.migration_0();
        await bitcoinAddressDao.migration_0();
      }),
      Migration(10, 11, () async {
        await transactionInfoDao.migration_1();
      }),
      Migration(11, 12, () async {}),
    ];

    migrationContainer.addMigrations(migrations);
  }

  Future<void> init(Database database) async {
    await initDatabase(database);
    buildMigration();
    initDAO();
  }

  static Future<Database> getDatabase() async {
    Database database;
    String dbPath = "";
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;

      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      dbPath = join(appDocumentsDir.path, dbFolder, dbName);
      database = await databaseFactory.openDatabase(
        dbPath,
      );
    } else {
      var path = await getDatabasesPath();
      dbPath = join(path, dbFolder, dbName);
      database = await openDatabase(
        dbPath,
      );
    }
    logger.i("dbPath: $dbPath");
    return database;
  }

  static Future<Database> getInMemoryDatabase() async {
    Database database;
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      database = await databaseFactory.openDatabase(
        inMemoryDatabasePath,
      );
    } else {
      database = await openDatabase(
        ":memory:",
      );
    }
    return database;
  }

  Future<void> initDatabase(Database database) async {
    try {
      if (db.isOpen) {
        return;
      }
    } catch (e) {
      logger.e(e);
    }
    db = database;
  }

  Future<void> buildDatabase(
      {bool isTesting = false, int oldVersion = 1}) async {
    List<Migration>? upgradeMigrations =
        migrationContainer.findMigrationPath(oldVersion, version);
    logger.i("Migration appDatabase from Ver.$oldVersion to Ver.$version");
    if (upgradeMigrations != null) {
      for (Migration migration in upgradeMigrations) {
        await migration.migrate();
      }
    } else {
      logger.w("nothing to migrate");
    }

    await checkAndUpdateVersion();
  }

  /// Mark future

  // when db rebuild but table need to resync. this could be in eatch db table
  bool needsResync() {
    return dbReset;
  }

  // not inused for future use
  Future<void> checkAndUpdateVersion() async {
    // Get the current version from the database
    int currentVersion =
        (await db.rawQuery('PRAGMA user_version')).first.values.first as int;
    if (currentVersion < version) {
      // If current version is less than the required version
      logger.i(
          "Current version ($currentVersion) is less than required version ($version)");
    }
    await db.execute('PRAGMA user_version = $version');
  }
}

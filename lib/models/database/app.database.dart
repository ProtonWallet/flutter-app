import 'dart:core';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/models/account.dao.impl.dart';
import 'package:wallet/models/address.dao.impl.dart';
import 'package:wallet/models/bitcoin.address.dao.impl.dart';
import 'package:wallet/models/contacts.dao.impl.dart';
import 'package:wallet/models/exchangerate.dao.impl.dart';
import 'package:wallet/models/transaction.dao.impl.dart';
import 'package:wallet/models/transaction.info.dao.impl.dart';
import 'package:wallet/models/wallet.dao.impl.dart';

import 'migration.container.dart';
import 'migration.dart';

class AppDatabase {
  static String dbFolder = "databases";
  static String dbName = "proton_wallet_db";
  static String versionKey = "db_version";

  // current version of the database
  int version = 24;

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
  late ExchangeRateDao exchangeRateDao;

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
    await exchangeRateDao.dropTable();
  }

  void initDAO() {
    walletDao = WalletDaoImpl(db);
    accountDao = AccountDaoImpl(db);
    transactionDao = TransactionDaoImpl(db);
    contactsDao = ContactsDaoImpl(db);
    addressDao = AddressDaoImpl(db);
    bitcoinAddressDao = BitcoinAddressDaoImpl(db);
    transactionInfoDao = TransactionInfoDaoImpl(db);
    exchangeRateDao = ExchangeRateDaoImpl(db);
  }

  void buildMigration() {
    final List<Migration> migrations = [
      Migration(1, 2, () async {}),
      Migration(2, 3, () async {
        await transactionDao.migration_0();
      }),
      Migration(3, 4, () async {}),
      Migration(4, 5, () async {}),
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
      Migration(11, 12, () async {
        await transactionInfoDao.migration_2();
      }),
      Migration(12, 13, () async {}),
      Migration(13, 14, () async {
        await exchangeRateDao.migration_0();
      }),
      Migration(14, 15, () async {
        await transactionDao.migration_3();
      }),
      Migration(15, 16, () async {
        await bitcoinAddressDao.migration_1();
      }),
      Migration(16, 17, () async {
        await transactionDao.migration_4();
      }),
      Migration(17, 18, () async {}),
      Migration(18, 19, () async {}),
      Migration(19, 20, () async {}),
      Migration(20, 21, () async {}),
      Migration(21, 22, () async {
        await walletDao.migration_0();
        await accountDao.migration_0();
      }),
      Migration(22, 23, () async {}),
      Migration(23, 24, () async {
        await accountDao.migration_1();
      }),
      Migration(24, 25, () async {}),
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
      final databaseFactory = databaseFactoryFfi;

      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      dbPath = join(appDocumentsDir.path, dbFolder, dbName);
      database = await databaseFactory.openDatabase(
        dbPath,
      );
    } else {
      final path = await getDatabasesPath();
      dbPath = join(path, dbFolder, dbName);
      database = await openDatabase(
        dbPath,
      );
    }
    logger.d("dbPath: $dbPath");
    return database;
  }

  static Future<Database> getInMemoryDatabase() async {
    Database database;
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      final databaseFactory = databaseFactoryFfi;
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
        logger.i("db is open return");
        return;
      }
    } catch (e) {
      logger.e(e);
    }
    logger.i("set inited Database");
    db = database;
  }

  // TODO(fix): fix me. the oldversion somehow is not correct. we should try to use the version from the database `user_version`.
  // TODO(fix): future we also need to check the db schema is correct or not. then decide to rebuild it or not.
  Future<void> buildDatabase(
      {bool isTesting = false, int oldVersion = 1}) async {
    final List<Migration>? upgradeMigrations =
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
    final int currentVersion =
        (await db.rawQuery('PRAGMA user_version')).first.values.first! as int;
    if (currentVersion < version) {
      // If current version is less than the required version
      logger.i(
          "Current version ($currentVersion) is less than required version ($version)");
    }
    await db.execute('PRAGMA user_version = $version');
  }
}

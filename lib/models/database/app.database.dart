import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/models/account.dao.impl.dart';
import 'package:wallet/models/bitcoin.address.dao.impl.dart';
import 'package:wallet/models/contacts.dao.impl.dart';
import 'package:wallet/models/database/address.database.dart';
import 'package:wallet/models/database/bitcoin.address.database.dart';
import 'package:wallet/models/database/contacts.database.dart';
import 'package:wallet/models/database/transaction.database.dart';
import 'package:wallet/models/database/transaction.info.database.dart';
import 'package:wallet/models/database/wallet.database.dart';
import 'package:wallet/models/database/account.database.dart';
import 'package:wallet/models/address.dao.impl.dart';
import 'package:wallet/models/transaction.dao.impl.dart';
import 'package:wallet/models/transaction.info.dao.impl.dart';
import 'package:wallet/models/wallet.dao.impl.dart';

import 'migration.dart';
import 'migration.container.dart';

class AppDatabase
    implements AccountDatabase, TransactionDatabase, WalletDatabase {
  static String dbFolder = "databases";
  static String dbName = "proton_wallet_db";
  int version = 10;
  late Database db;
  late MigrationContainer migrationContainer;

  late AccountDao accountDao;
  late WalletDao walletDao;
  late TransactionDao transactionDao;
  late ContactsDao contactsDao;
  late AddressDao addressDao;
  late BitcoinAddressDao bitcoinAddressDao;
  late TransactionInfoDao transactionInfoDao;

  List<Migration> migrations = [
    Migration(1, 2, (Database db) async {
      WalletDatabase.migration_0.migrate(db);
      AccountDatabase.migration_0.migrate(db);
    }),
    Migration(2, 3, (Database db) async {
      TransactionDatabase.migration_0.migrate(db);
    }),
    Migration(3, 4, (Database db) async {
      WalletDatabase.migration_1.migrate(db);
    }),
    Migration(4, 5, (Database db) async {
      WalletDatabase.migration_2.migrate(db);
    }),
    Migration(5, 6, (Database db) async {
      ContactsDatabase.migration_0.migrate(db);
    }),
    Migration(6, 7, (Database db) async {
      AddressDatabase.migration_0.migrate(db);
    }),
    Migration(7, 8, (Database db) async {
      TransactionDatabase.migration_1.migrate(db);
    }),
    Migration(8, 9, (Database db) async {
      TransactionDatabase.migration_2.migrate(db);
    }),
    Migration(9, 10, (Database db) async {
      TransactionInfoDatabase.migration_0.migrate(db);
      BitcoinAddressDatabase.migration_0.migrate(db);
    }),
  ];

  AppDatabase() {
    migrationContainer = MigrationContainer();
    migrationContainer.addMigrations(migrations);
  }

  void reset() {
    dropAllTables();
    buildDatabase();
  }

  void dropAllTables() {
    WalletDatabase.dropTables(db);
    AccountDatabase.dropTables(db);
    TransactionDatabase.dropTables(db);
    ContactsDatabase.dropTables(db);
    AddressDatabase.dropTables(db);
  }

  void initDAO() {
    accountDao = AccountDaoImpl(db);
    walletDao = WalletDaoImpl(db);
    transactionDao = TransactionDaoImpl(db);
    contactsDao = ContactsDaoImpl(db);
    addressDao = AddressDaoImpl(db);
    bitcoinAddressDao = BitcoinAddressDaoImpl(db);
    transactionInfoDao = TransactionInfoDaoImpl(db);
  }

  Future<void> init(Database database) async {
    await initDatabase(database);
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
      // db is not initialed;
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
        migration.migrate(db);
      }
    } else {
      logger.w("nothing to migrate");
    }
  }
}

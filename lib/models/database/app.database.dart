import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/models/database/transaction.database.dart';
import 'package:wallet/models/database/wallet.database.dart';
import 'package:wallet/models/database/account.database.dart';
import 'package:wallet/models/transaction.dao.impl.dart';

import '../../helper/logger.dart';
import '../account.dao.impl.dart';
import '../wallet.dao.impl.dart';
import 'migration.dart';
import 'migration.container.dart';

class AppDatabase
    implements AccountDatabase, TransactionDatabase, WalletDatabase {
  String dbFolder = "databases";
  String dbName = "proton_wallet_db";
  int version = 3;
  late Database db;
  late MigrationContainer migrationContainer;

  late AccountDao accountDao;
  late WalletDao walletDao;
  late TransactionDao transactionDao;

  List<Migration> migrations = [
    Migration(1, 2, (Database db) async {
      WalletDatabase.migration_0.migrate(db);
      AccountDatabase.migration_0.migrate(db);
    }),
    Migration(2, 3, (Database db) async {
      TransactionDatabase.migration_0.migrate(db);
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
  }

  void initDAO() {
    accountDao = AccountDaoImpl(db);
    walletDao = WalletDaoImpl(db);
    transactionDao = TransactionDaoImpl(db);
  }

  Future<void> init() async {
    await initDB();
    initDAO();
  }

  Future<void> initDB() async {
    try {
      if (db.isOpen) {
        return;
      }
    } catch (e) {
      // db is not initialed;
    }
    late String dbPath;
    if (Platform.isWindows) {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      dbPath = join(appDocumentsDir.path, dbFolder, dbName);
      db = await databaseFactory.openDatabase(
        dbPath,
      );
    } else {
      var path = await getDatabasesPath();
      dbPath = join(path, dbFolder, dbName);
      db = await openDatabase(
        dbPath,
      );
    }
  }

  Future<void> buildDatabase({int oldVersion = 1}) async {
    await init();
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

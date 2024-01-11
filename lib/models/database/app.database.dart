import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/models/database/transaction.database.dart';
import 'package:wallet/models/database/wallet.database.dart';
import 'package:wallet/models/database/account.database.dart';

import '../../helper/logger.dart';
import 'migration.dart';
import 'migration.container.dart';

class AppDatabase
    implements AccountDatabase, TransactionDatabase, WalletDatabase {
  String DB_FOLDER = "databases";
  String DB_NAME = "proton_wallet_db";
  int VERSION = 3;
  late Database db;
  late MigrationContainer migrationContainer;

  AppDatabase() {
    migrationContainer = MigrationContainer();
  }

  List<Migration> migrations = [
    Migration(1, 2, (Database db) async {
      WalletDatabase.MIGRATION_0.migrate(db);
      AccountDatabase.MIGRATION_0.migrate(db);
    }),
    Migration(2, 3, (Database db) async {
      TransactionDatabase.MIGRATION_0.migrate(db);
    }),
  ];

  Future<void> buildDatabase({int oldVersion = 1}) async {
    late String dbPath;
    if (Platform.isWindows) {
      sqfliteFfiInit();
      var databaseFactory = databaseFactoryFfi;
      final Directory appDocumentsDir =
          await getApplicationDocumentsDirectory();
      dbPath = join(appDocumentsDir.path, DB_FOLDER, DB_NAME);
      db = await databaseFactory.openDatabase(
        dbPath,
      );
    } else {
      var path = await getDatabasesPath();
      dbPath = join(path, DB_FOLDER, DB_NAME);
      db = await openDatabase(
        dbPath,
      );
    }
    migrationContainer.addMigrations(migrations);
    List<Migration>? upgradeMigrations =
        migrationContainer.findMigrationPath(oldVersion, VERSION);
    logger.i("Migration appDatabase from Ver.$oldVersion to Ver.$VERSION");
    if (upgradeMigrations != null) {
      for (Migration migration in upgradeMigrations) {
        migration.migrate(db);
      }
    } else {
      logger.w("nothing to migrate");
    }
  }
}

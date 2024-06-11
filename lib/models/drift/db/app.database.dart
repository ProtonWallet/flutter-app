import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:wallet/managers/preferences/preferences.manager.dart';

// Include the tables file
import 'package:wallet/models/drift/tables/user.keys.dart';
import 'package:wallet/models/drift/tables/users.dart';
import 'package:wallet/models/drift/tables/wallet.user.settings.dart';

// Include the generated file
part 'app.database.g.dart';

// Define the Drift database
@DriftDatabase(tables: [UsersTable, UserKeysTable, WalletUserSettingsTable])
class AppDatabase extends _$AppDatabase {
  final PreferencesManager shared;
  AppDatabase(this.shared) : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Add more methods here as needed for your queries and operations
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) {
          return m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from == 1) {
            // await m.addColumn(items, items.quantity);
          }
        },
      );
}

Future<void> rebuildDatabase() async {
  final file = await _getPath();
  if (await file.exists()) {
    await file.delete();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final file = await _getPath();
    return NativeDatabase(file);
  });
}

Future<File> _getPath() async {
  const dbFolder = "databases";
  const dbName = "drift_proton_wallet_db";
  final appDocumentsDir = await getApplicationDocumentsDirectory();
  final file = File(p.join(appDocumentsDir.path, dbFolder, dbName));
  return file;
}

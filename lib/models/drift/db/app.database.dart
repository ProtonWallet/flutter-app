import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:wallet/models/drift/tables/user.keys.dart';

import '../tables/users.dart';

// Include the generated file
part 'app.database.g.dart';

// Define the Drift database
@DriftDatabase(tables: [UsersTable, UserKeysTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Add more methods here as needed for your queries and operations
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    const dbFolder = "databases";
    const dbName = "proton_wallet_db";
    final appDocumentsDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(appDocumentsDir.path, dbFolder, dbName));
    return NativeDatabase(file);
  });
}

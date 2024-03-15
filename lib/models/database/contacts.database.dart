import 'package:sqflite/sqflite.dart';
import 'package:wallet/models/database/base.database.dart';
import 'package:wallet/models/database/database.migration.dart';

abstract class ContactsDatabase extends BaseDatabase {
  static DatabaseMigration migration_0 = DatabaseMigration((Database db) async {
    await db.execute('''
        CREATE TABLE IF NOT EXISTS `contacts` (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          serverContactID TEXT,
          name TEXT,
          email TEXT,
          canonicalEmail TEXT,
          isProton INTEGER
        )
    ''');
  });

  static void Function(Database db) dropTables = (Database db) {
    db.execute('''
      DROP TABLE IF EXISTS `contacts`
    ''');
  };
}

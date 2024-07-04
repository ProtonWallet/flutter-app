import 'package:wallet/models/database/base.database.dart';

class ContactsDatabase extends BaseDatabase {
  ContactsDatabase(super.db, super.tableName);

  @override
  Future<void> migration_0() async {
    return await createTable('''
        CREATE TABLE IF NOT EXISTS `contacts` (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          serverContactID TEXT,
          name TEXT,
          email TEXT,
          canonicalEmail TEXT,
          isProton INTEGER
        )
    ''');
  }
}

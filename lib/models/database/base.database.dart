import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:wallet/helper/logger.dart';

abstract class BaseDatabase {
  final Database db;
  final String tableName;
  BaseDatabase(this.db, this.tableName);

  Future<void> migration_0();

  Future<void> createTable(String createTableQuery) async {
    await db.execute(createTableQuery);
  }

  // unsafe. injection possible. but its hardcode in code. so its ok.
  Future<void> addColumn(String columnName, String columnType) async {
    if (!_isValidTableName(tableName)) {
      throw getException();
    }
    await db
        .execute('ALTER TABLE $tableName ADD COLUMN $columnName $columnType;');
  }

  Future<void> dropColumn(String columnName) async {
    if (!_isValidTableName(tableName)) {
      throw getException();
    }
    await db.execute('ALTER TABLE $tableName DROP COLUMN $columnName;');
  }

  Future<void> dropTable() async {
    if (!_isValidTableName(tableName)) {
      throw getException();
    }
    await db.execute('DROP TABLE IF EXISTS `$tableName`');
  }

  Future<void> rebuildTable() async {
    await dropTable();
    await migration_0();
  }

  Exception getException() {
    return Exception('Invalid table name $tableName');
  }

  bool _isValidTableName(String tableName) {
    final RegExp validTableName = RegExp(r'^[a-zA-Z0-9_]+$');
    return validTableName.hasMatch(tableName);
  }

  Future<void> printTableSchema() async {
    final List<Map<String, dynamic>> schema =
        await db.rawQuery('PRAGMA table_info($tableName)');

    for (var column in schema) {
      String columnDetails = '''
        Column: ${column['name']}
        Type: ${column['type']}
        Not Null: ${column['notnull']}
        Default Value: ${column['dflt_value']}
        Primary Key: ${column['pk']}
        ---
      ''';
      logger.d(columnDetails);
    }
  }
}

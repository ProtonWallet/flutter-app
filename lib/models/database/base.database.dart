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

  Future<void> _addColumnIfNotExists(
      String columnName, String columnType) async {
    // Query to check if the column exists
    final result = await db.rawQuery('PRAGMA table_info($tableName)');

    // Check if column already exists
    bool columnExists = result.any((column) => column['name'] == columnName);
    // Add column if it doesn't exist
    if (!columnExists) {
      await db.execute(
          'ALTER TABLE $tableName ADD COLUMN $columnName $columnType;');
    }
  }

  // unsafe. injection possible. but its hardcode in code. so its ok.
  Future<void> addColumn(String columnName, String columnType) async {
    if (!_isValidTableName(tableName)) {
      throw getException();
    }
    await _addColumnIfNotExists(columnName, columnType);
  }

  Future<void> addIndex(String columnName) async {
    if (!_isValidTableName(tableName)) {
      throw getException();
    }
    await db.execute("""
      CREATE INDEX IF NOT EXISTS idx_$columnName ON $tableName($columnName)
    """);
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

import 'package:sqflite/sqflite.dart';

class DatabaseMigration {
  late void Function(Database db) migrate;
  DatabaseMigration(this.migrate);
}

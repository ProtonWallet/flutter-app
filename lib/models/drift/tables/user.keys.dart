// Define the User table
import 'package:drift/drift.dart';

@DataClassName('UserKey')
class UserKeysTable extends Table {
  TextColumn get keyId => text()();
  TextColumn get userId => text()();
  IntColumn get version => integer()();
  TextColumn get privateKey => text()();
  TextColumn get token => text().nullable()();
  TextColumn get fingerprint => text().nullable()();
  BoolColumn get primary => boolean()();

  @override
  Set<Column> get primaryKey => {keyId, userId};
}

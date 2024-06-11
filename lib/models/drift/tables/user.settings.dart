// Define the User table
import 'package:drift/drift.dart';

// @DataClassName('ProtonUserSettings')
class UserSettings extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();

  @override
  Set<Column> get primaryKey => {id};
}

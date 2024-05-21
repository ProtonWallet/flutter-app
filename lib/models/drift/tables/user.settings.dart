// Define the User table
import 'package:drift/drift.dart';

// @DataClassName('ProtonUserSettings')
class UserSettings extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 50)();
  TextColumn get email => text().withLength(min: 1, max: 100)();

  @override
  Set<Column> get primaryKey => {id};
}

// Define the User table
import 'package:drift/drift.dart';

@DataClassName('ProtonAddress')
class AddressesTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  IntColumn get version => integer()();
  TextColumn get privateKey => text().nullable()();
  TextColumn get token => text().nullable()();
  TextColumn get fingerprint => text().nullable()();
  BoolColumn get primary => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

// Define the User table
import 'package:drift/drift.dart';

@DataClassName('DriftUserKey')
class UserKeysTable extends Table {
  TextColumn get keyId => text()();
  TextColumn get userId => text()();
  IntColumn get version => integer()();
  TextColumn get privateKey => text()();
  TextColumn get token => text().nullable()();
  TextColumn get fingerprint => text().nullable()();
  TextColumn get recoverySecret => text().nullable()();
  TextColumn get recoverySecretSignature => text().nullable()();
  IntColumn get primary => integer()();

  @override
  Set<Column> get primaryKey => {keyId, userId};
}

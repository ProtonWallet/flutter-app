// Define the User table
import 'package:drift/drift.dart';
import 'package:wallet/models/drift/tables/table.extension.dart';

@DataClassName('DriftProtonUser')
@TableIndex(name: 'user_id_index', columns: {#userId})
class UsersTable extends Table with AutoIncrementingPrimaryKey {
  TextColumn get userId => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)(); //username
  Int64Column get usedSpace => int64()();
  TextColumn get currency => text().withLength(min: 1, max: 32)();
  IntColumn get credit => integer()();
  Int64Column get createTime => int64()();
  Int64Column get maxSpace => int64()();
  Int64Column get maxUpload => int64()();
  IntColumn get role => integer()();
  IntColumn get private => integer()();
  IntColumn get subscribed => integer()();
  IntColumn get services => integer()();
  IntColumn get delinquent => integer()();
  TextColumn get organizationPrivateKey => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get displayName => text().nullable()();
}

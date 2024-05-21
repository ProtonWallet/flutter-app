// Define the User table
import 'package:drift/drift.dart';
import 'package:wallet/models/drift/tables/table.extension.dart';

@DataClassName('User')
@TableIndex(name: 'user_id_index', columns: {#userId})
class UsersTable extends Table with AutoIncrementingPrimaryKey {
  TextColumn get userId => text()();
  TextColumn get name => text().withLength(min: 1, max: 50)(); //username
  IntColumn get usedSpace => integer()();
  TextColumn get currency => text().withLength(min: 1, max: 10)();
  IntColumn get credit => integer()();
  IntColumn get createTime => integer()();
  IntColumn get maxSpace => integer()();
  IntColumn get maxUpload => integer()();
  IntColumn get role => integer()();
  BoolColumn get private => boolean()();
  BoolColumn get subscribed => boolean()();
  BoolColumn get services => boolean()();
  BoolColumn get delinquent => boolean()();
  TextColumn get organizationPrivateKey => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get displayName => text().nullable()();
}

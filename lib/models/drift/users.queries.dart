import 'package:drift/drift.dart';

import 'db/app.database.dart';
import 'tables/users.dart';

part 'users.queries.g.dart';

@DriftAccessor(tables: [UsersTable])
class UserQueries extends DatabaseAccessor<AppDatabase>
    with _$UserQueriesMixin {
  UserQueries(super.attachedDatabase);

  Future<DriftProtonUser> getUser(String userId) {
    return (select(usersTable)..where((tbl) => tbl.userId.equals(userId)))
        .getSingle();
  }

  Stream<DriftProtonUser> watchUser(String userId) {
    return (select(usersTable)..where((tbl) => tbl.userId.equals(userId)))
        .watchSingle();
  }

  Future<void> insertOrUpdateItem(DriftProtonUser item) async {
    await into(usersTable).insertOnConflictUpdate(item);
  }

  Future<void> clearTable() async {
    await delete(usersTable).go();
  }
}

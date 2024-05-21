import 'package:drift/drift.dart';

import 'db/app.database.dart';
import 'tables/users.dart';

part 'users.queries.g.dart';

@DriftAccessor(tables: [UsersTable])
class UserQueries extends DatabaseAccessor<AppDatabase>
    with _$UserQueriesMixin {
  UserQueries(super.db);

  Future<User> getUser(String userId) {
    return (select(usersTable)..where((tbl) => tbl.userId.equals(userId)))
        .getSingle();
  }

  Stream<User> watchUser(String userId) {
    return (select(usersTable)..where((tbl) => tbl.userId.equals(userId)))
        .watchSingle();
  }
}

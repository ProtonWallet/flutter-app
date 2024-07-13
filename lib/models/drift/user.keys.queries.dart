import 'package:drift/drift.dart';

import 'db/app.database.dart';
import 'tables/user.keys.dart';

part 'user.keys.queries.g.dart';

@DriftAccessor(tables: [UserKeysTable])
class UserKeysQueries extends DatabaseAccessor<AppDatabase>
    with _$UserKeysQueriesMixin {
  UserKeysQueries(super.attachedDatabase);

  Future<List<UserKey>> getUseKeys(String userId) {
    return (select(userKeysTable)..where((tbl) => tbl.userId.equals(userId)))
        .get();
  }

  Stream<List<UserKey>> watchUserKeys(String userId) {
    return (select(userKeysTable)..where((tbl) => tbl.userId.equals(userId)))
        .watch();
  }
}

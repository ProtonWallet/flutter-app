import 'package:drift/drift.dart';
import 'package:wallet/rust/proton_api/proton_users.dart';

import 'db/app.database.dart';
import 'tables/user.keys.dart';

part 'user.keys.queries.g.dart';

@DriftAccessor(tables: [UserKeysTable])
class UserKeysQueries extends DatabaseAccessor<AppDatabase>
    with _$UserKeysQueriesMixin {
  UserKeysQueries(super.attachedDatabase);

  Future<List<DriftUserKey>> getUseKeys(String userId) {
    return (select(userKeysTable)..where((tbl) => tbl.userId.equals(userId)))
        .get();
  }

  Stream<List<DriftUserKey>> watchUserKeys(String userId) {
    return (select(userKeysTable)..where((tbl) => tbl.userId.equals(userId)))
        .watch();
  }

  Future<void> insertOrUpdateItem(DriftUserKey item) async {
    await into(userKeysTable).insertOnConflictUpdate(item);
  }

  Future<void> clearTable() async {
    await delete(userKeysTable).go();
  }

  static List<Map<String, dynamic>> toJsonList(List<DriftUserKey> items) {
    return items.map((item) => item.toJson()).toList();
  }
}

extension DriftUserKeyArray on List<DriftUserKey> {
  List<ProtonUserKey> toProtonUserKeys() {
    return map((e) => e.toProtonUserKey()).toList();
  }
}

extension DriftUserKeyExt on DriftUserKey {
  ProtonUserKey toProtonUserKey() {
    return ProtonUserKey(
      id: keyId,
      version: version,
      privateKey: privateKey,
      recoverySecret: recoverySecret,
      recoverySecretSignature: recoverySecretSignature,
      token: token,
      fingerprint: fingerprint ?? '',
      primary: primary,
      active: 1,
    );
  }
}

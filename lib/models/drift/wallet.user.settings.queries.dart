import 'package:drift/drift.dart';
import 'package:wallet/models/drift/tables/wallet.user.settings.dart';

import 'db/app.database.dart';

part 'wallet.user.settings.queries.g.dart';

@DriftAccessor(tables: [WalletUserSettingsTable])
class WalletUserSettingsQueries extends DatabaseAccessor<AppDatabase>
    with _$WalletUserSettingsQueriesMixin {
  WalletUserSettingsQueries(super.attachedDatabase);

  Future<WalletUserSettings?> getWalletUserSettings(String userId) {
    return (select(walletUserSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .getSingleOrNull();
  }

  Stream<WalletUserSettings> watchUser(String userId) {
    return (select(walletUserSettingsTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .watchSingle();
  }

  Future<void> insertOrUpdateItem(WalletUserSettings item) async {
    await into(walletUserSettingsTable).insertOnConflictUpdate(item);
  }

  Future<void> clearTable() async {
    await delete(walletUserSettingsTable).go();
  }
}

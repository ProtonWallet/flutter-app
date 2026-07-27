// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.user.settings.queries.dart';

// ignore_for_file: type=lint
mixin _$WalletUserSettingsQueriesMixin on DatabaseAccessor<AppDatabase> {
  $WalletUserSettingsTableTable get walletUserSettingsTable =>
      attachedDatabase.walletUserSettingsTable;
  WalletUserSettingsQueriesManager get managers =>
      WalletUserSettingsQueriesManager(this);
}

class WalletUserSettingsQueriesManager {
  final _$WalletUserSettingsQueriesMixin _db;
  WalletUserSettingsQueriesManager(this._db);
  $$WalletUserSettingsTableTableTableManager get walletUserSettingsTable =>
      $$WalletUserSettingsTableTableTableManager(
        _db.attachedDatabase,
        _db.walletUserSettingsTable,
      );
}

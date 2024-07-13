// Define the User table
import 'package:drift/drift.dart';

// gloabl wallet settings
@DataClassName('WalletUserSettings')
class WalletUserSettingsTable extends Table {
  TextColumn get userId => text()();
  TextColumn get bitcoinUnit => text().withLength(min: 1, max: 32)();
  TextColumn get fiatCurrency => text().withLength(min: 1, max: 32)();
  BoolColumn get hideEmptyUsedAddresses => boolean()();
  // TODO(fix): showWalletRecovery need to be removed
  BoolColumn get showWalletRecovery => boolean()();
  RealColumn get twoFactorAmountThreshold => real()();

  @override
  Set<Column> get primaryKey => {userId};
}

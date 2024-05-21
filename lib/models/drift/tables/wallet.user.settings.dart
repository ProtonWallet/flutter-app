// Define the User table
import 'package:drift/drift.dart';
import 'package:wallet/models/drift/tables/users.dart';

// gloabl wallet settings
// @DataClassName('ProtonWalletUserSettings')
class WalletUserSettings extends Table {
  TextColumn get userId => text().references(UsersTable, #userId)();
  TextColumn get bitcoinUnit => text().withLength(min: 1, max: 10)();
  TextColumn get fiatCurrency => text().withLength(min: 1, max: 10)();
  BoolColumn get hideEmptyUsedAddresses => boolean()();
  BoolColumn get showWalletRecovery => boolean()();
  RealColumn get twoFactorAmountThreshold => real()();

  @override
  Set<Column> get primaryKey => {userId};
}

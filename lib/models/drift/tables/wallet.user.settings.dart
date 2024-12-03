// Define the User table
import 'package:drift/drift.dart';

// gloabl wallet settings
@DataClassName('WalletUserSettings')
class WalletUserSettingsTable extends Table {
  TextColumn get userId => text()();
  TextColumn get bitcoinUnit => text().withLength(min: 1, max: 32)();
  TextColumn get fiatCurrency => text().withLength(min: 1, max: 32)();
  BoolColumn get hideEmptyUsedAddresses => boolean()();
  @Deprecated("showWalletRecovery need to be removed")
  BoolColumn get showWalletRecovery => boolean()();
  RealColumn get twoFactorAmountThreshold => real()();
  BoolColumn get receiveInviterNotification => boolean()();
  BoolColumn get receiveEmailIntegrationNotification => boolean()();
  BoolColumn get walletCreated => boolean()();
  BoolColumn get acceptTermsAndConditions => boolean()();

  @override
  Set<Column> get primaryKey => {userId};
}

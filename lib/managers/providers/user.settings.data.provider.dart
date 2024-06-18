import 'dart:async';

import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/models/drift/wallet.user.settings.queries.dart';
import 'package:wallet/rust/api/api_service/settings_client.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class UserSettingsDataProvider implements DataProvider {
  final String userID;
  final SettingsClient settingsClient;

  //
  final WalletUserSettingsQueries settingsQueries;

  final defaultTwoFactorAmountThreshold = 1000;

  // need to monitor the db changes apply to this cache
  WalletUserSettings? settingsData;

  UserSettingsDataProvider(
    this.userID,
    this.settingsQueries,
    this.settingsClient,
  );

  @override
  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>();

  Future<WalletUserSettings?> _getFromDB() async {
    var settings = settingsQueries.getWalletUserSettings(userID);
    return settings;
  }

  Future<WalletUserSettings?> getSettings() async {
    if (settingsData != null) {
      return settingsData;
    }

    settingsData = await _getFromDB();
    if (settingsData != null) {
      return settingsData;
    }

    // try to fetch from server:
    ApiWalletUserSettings apiSettings = await settingsClient.getUserSettings();
    insertUpdate(apiSettings);

    settingsData = await _getFromDB();
    if (settingsData != null) {
      return settingsData;
    }

    return null;
  }

  Future<void> insertUpdate(ApiWalletUserSettings settings) async {
    settingsQueries.insertOrUpdateItem(WalletUserSettings(
      userId: userID,
      bitcoinUnit: settings.bitcoinUnit.enumToString(),
      fiatCurrency: settings.fiatCurrency.enumToString(),
      hideEmptyUsedAddresses: settings.hideEmptyUsedAddresses == 1,
      showWalletRecovery: settings.showWalletRecovery == 1,
      twoFactorAmountThreshold:
          (settings.twoFactorAmountThreshold ?? defaultTwoFactorAmountThreshold)
              .toDouble(),
    ));
  }

  Future<void> preLoad() async {
    // this is to preload the contacts
    await getSettings();
  }

  @override
  Future<void> clear() async {
    settingsQueries.clearTable();
    dataUpdateController.close();
  }
}

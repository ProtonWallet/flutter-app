import 'dart:async';

import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/helper/fiat.currency.helper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/models/drift/wallet.user.settings.queries.dart';
import 'package:wallet/rust/api/api_service/settings_client.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
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

  ProtonExchangeRate exchangeRate = const ProtonExchangeRate(
      id: 'default',
      bitcoinUnit: BitcoinUnit.btc,
      fiatCurrency: defaultFiatCurrency,
      exchangeRateTime: '',
      exchangeRate: 1,
      cents: 1);
  BitcoinUnit bitcoinUnit = BitcoinUnit.btc;
  FiatCurrency fiatCurrency = FiatCurrency.usd;

  StreamController<UserSettingDataUpdated> dataUpdateController =
      StreamController<UserSettingDataUpdated>();

  StreamController<ExchangeRateDataUpdated> exchangeRateUpdateController =
      StreamController<ExchangeRateDataUpdated>();

  StreamController<BitcoinUnitDataUpdated> bitcoinUnitUpdateController =
      StreamController<BitcoinUnitDataUpdated>();

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

  void updateBitcoinUnit(BitcoinUnit bitcoinUnit) {
    this.bitcoinUnit = bitcoinUnit;
    bitcoinUnitUpdateController.add(BitcoinUnitDataUpdated());
  }

  Future<void> updateFiatCurrency(FiatCurrency fiatCurrency) async {
    if (this.fiatCurrency != fiatCurrency) {
      this.fiatCurrency = fiatCurrency;
      insertUpdate(ApiWalletUserSettings(
        bitcoinUnit: settingsData!.bitcoinUnit.toBitcoinUnit(),
        fiatCurrency: fiatCurrency,
        hideEmptyUsedAddresses: settingsData!.hideEmptyUsedAddresses ? 1 : 0,
        showWalletRecovery: settingsData!.showWalletRecovery ? 1 : 0,
        twoFactorAmountThreshold:
            settingsData!.twoFactorAmountThreshold.toInt(),
      ));
      ProtonExchangeRate exchangeRate =
          await ExchangeRateService.getExchangeRate(fiatCurrency);
      updateExchangeRate(exchangeRate);
    }
  }

  void updateExchangeRate(ProtonExchangeRate exchangeRate) {
    this.exchangeRate = exchangeRate;
    logger.i(
        "Updating exchangeRate in new user setting provider (${exchangeRate.fiatCurrency.name}) = ${exchangeRate.exchangeRate}");
    exchangeRateUpdateController.add(ExchangeRateDataUpdated());
  }

  Future<void> insertUpdate(ApiWalletUserSettings settings) async {
    await settingsQueries.insertOrUpdateItem(WalletUserSettings(
      userId: userID,
      bitcoinUnit: settings.bitcoinUnit.enumToString(),
      fiatCurrency: settings.fiatCurrency.enumToString(),
      hideEmptyUsedAddresses: settings.hideEmptyUsedAddresses == 1,
      showWalletRecovery: settings.showWalletRecovery == 1,
      twoFactorAmountThreshold:
          (settings.twoFactorAmountThreshold ?? defaultTwoFactorAmountThreshold)
              .toDouble(),
    ));
    settingsData = await _getFromDB();
    dataUpdateController.add(UserSettingDataUpdated());
  }

  String getFiatCurrencyName({FiatCurrency? fiatCurrency}) {
    if (settingsData != null) {
      fiatCurrency ??= settingsData!.fiatCurrency.toFiatCurrency();
    } else {
      fiatCurrency ??= FiatCurrency.usd;
    }
    return fiatCurrency.name.toString().toUpperCase();
  }

  String getFiatCurrencySign({FiatCurrency? fiatCurrency}) {
    if (settingsData != null) {
      fiatCurrency ??= settingsData!.fiatCurrency.toFiatCurrency();
    } else {
      fiatCurrency ??= FiatCurrency.usd;
    }
    return fiatCurrency2Info.containsKey(fiatCurrency)
        ? fiatCurrency2Info[fiatCurrency]!.sign
        : "\$";
  }

  Future<void> preLoad() async {
    // this is to preload the contacts
    await getSettings();
  }

  @override
  Future<void> clear() async {
    settingsQueries.clearTable();
    dataUpdateController.close();
    exchangeRateUpdateController.close();
    bitcoinUnitUpdateController.close();
  }
}

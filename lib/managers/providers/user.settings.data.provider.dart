import 'dart:async';

import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/models/drift/wallet.user.settings.queries.dart';
import 'package:wallet/rust/api/api_service/settings_client.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class UserSettingDataUpdated extends DataState {
  UserSettingDataUpdated();

  @override
  List<Object?> get props => [];
}

class FiatCurrencyDataUpdated extends DataState {
  FiatCurrencyDataUpdated();

  @override
  List<Object?> get props => [];
}

class ExchangeRateDataUpdated extends DataState {
  ExchangeRateDataUpdated();

  @override
  List<Object?> get props => [];
}

class BitcoinUnitDataUpdated extends DataState {
  BitcoinUnitDataUpdated();

  @override
  List<Object?> get props => [];
}

class UserSettingsDataProvider extends DataProvider {
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

  ProtonExchangeRate exchangeRate = ProtonExchangeRate(
      id: 'default',
      bitcoinUnit: BitcoinUnit.btc,
      fiatCurrency: defaultFiatCurrency,
      exchangeRateTime: '',
      exchangeRate: BigInt.one,
      cents: BigInt.one);
  BitcoinUnit bitcoinUnit = BitcoinUnit.btc;
  FiatCurrency fiatCurrency = FiatCurrency.usd;

  StreamController<UserSettingDataUpdated> dataUpdateController =
      StreamController<UserSettingDataUpdated>();

  StreamController<ExchangeRateDataUpdated> exchangeRateUpdateController =
      StreamController<ExchangeRateDataUpdated>();

  StreamController<FiatCurrencyDataUpdated> fiatCurrencyUpdateController =
      StreamController<FiatCurrencyDataUpdated>();

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
    try {
      ApiWalletUserSettings apiSettings =
          await settingsClient.getUserSettings();
      insertUpdate(apiSettings);
    } catch (e, stacktrace) {
      logger.e("error: $e, stacktrace: $stacktrace");
    }
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

      var settings = await getSettings();
      if (settings != null) {
        insertUpdate(ApiWalletUserSettings(
          bitcoinUnit: settings.bitcoinUnit.toBitcoinUnit(),
          fiatCurrency: fiatCurrency,
          hideEmptyUsedAddresses: settings.hideEmptyUsedAddresses ? 1 : 0,
          twoFactorAmountThreshold:
              BigInt.from(settings.twoFactorAmountThreshold),
        ));
        ProtonExchangeRate exchangeRate =
            await ExchangeRateService.getExchangeRate(fiatCurrency);
        updateExchangeRate(exchangeRate);
      }
      fiatCurrencyUpdateController.add(FiatCurrencyDataUpdated());
    }
  }

  void updateExchangeRate(ProtonExchangeRate exchangeRate) {
    this.exchangeRate = exchangeRate;
    logger.i(
      "Updating exchangeRate in new user setting provider (${exchangeRate.fiatCurrency.name}) = ${exchangeRate.exchangeRate}",
    );
    exchangeRateUpdateController.add(ExchangeRateDataUpdated());
  }

  Future<void> insertUpdate(ApiWalletUserSettings settings) async {
    await settingsQueries.insertOrUpdateItem(WalletUserSettings(
      userId: userID,
      bitcoinUnit: settings.bitcoinUnit.enumToString(),
      fiatCurrency: settings.fiatCurrency.enumToString(),
      hideEmptyUsedAddresses: settings.hideEmptyUsedAddresses == 1,
      showWalletRecovery: false,
      twoFactorAmountThreshold: (settings.twoFactorAmountThreshold ??
              BigInt.from(defaultTwoFactorAmountThreshold))
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
    return CommonHelper.getFiatCurrencySign(fiatCurrency);
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
    fiatCurrencyUpdateController.close();
    bitcoinUnitUpdateController.close();
  }
}

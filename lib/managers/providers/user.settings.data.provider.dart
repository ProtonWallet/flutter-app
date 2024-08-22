import 'dart:async';

import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/models/drift/wallet.user.settings.queries.dart';
import 'package:wallet/rust/api/api_service/settings_client.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

const String displayBalanceKey = "user.settings.displayBalance";

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

class DisplayBalanceUpdated extends DataState {
  DisplayBalanceUpdated();

  @override
  List<Object?> get props => [];
}

class UserSettingsDataProvider extends DataProvider {
  final String userID;
  final SettingsClient settingsClient;
  final PreferencesManager shared;

  //
  final WalletUserSettingsQueries settingsQueries;

  final defaultTwoFactorAmountThreshold = 1000;

  // need to monitor the db changes apply to this cache
  WalletUserSettings? settingsData;
  bool displayBalance = true;

  UserSettingsDataProvider(
    this.userID,
    this.settingsQueries,
    this.settingsClient,
    this.shared,
  );

  ProtonExchangeRate exchangeRate = defaultExchangeRate;
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

  StreamController<DisplayBalanceUpdated> displayBalanceUpdateController =
      StreamController<DisplayBalanceUpdated>();

  Future<WalletUserSettings?> _getFromDB() async {
    final settings = settingsQueries.getWalletUserSettings(userID);
    return settings;
  }

  Future<void> loadFromServer() async {
    try {
      final ApiWalletUserSettings apiSettings =
          await settingsClient.getUserSettings();
      insertUpdate(apiSettings);
    } catch (e, stacktrace) {
      logger.e("error: $e, stacktrace: $stacktrace");
    }
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
    await loadFromServer();

    settingsData = await _getFromDB();
    if (settingsData != null) {
      return settingsData;
    }

    return null;
  }

  Future<void> setDisplayBalance(display) async {
    displayBalance = display;
    await shared.write(displayBalanceKey, displayBalance);
    displayBalanceUpdateController.add(DisplayBalanceUpdated());
  }

  Future<bool> getDisplayBalance() async {
    displayBalance = await shared.read(displayBalanceKey) ?? true;
    return displayBalance;
  }

  void updateBitcoinUnit(BitcoinUnit bitcoinUnit) {
    this.bitcoinUnit = bitcoinUnit;
    bitcoinUnitUpdateController.add(BitcoinUnitDataUpdated());
  }

  Future<void> acceptTermsAndConditions() async {
    await settingsClient.acceptTermsAndConditions();

    /// reload local db and cache
    await loadFromServer();
    settingsData = await _getFromDB();
  }

  Future<void> updateFiatCurrency(FiatCurrency fiatCurrency,
      {notify = true}) async {
    if (this.fiatCurrency != fiatCurrency) {
      this.fiatCurrency = fiatCurrency;

      final settings = await getSettings();
      if (settings != null) {
        insertUpdate(ApiWalletUserSettings(
          bitcoinUnit: settings.bitcoinUnit.toBitcoinUnit(),
          fiatCurrency: fiatCurrency,
          hideEmptyUsedAddresses: settings.hideEmptyUsedAddresses ? 1 : 0,
          twoFactorAmountThreshold:
              BigInt.from(settings.twoFactorAmountThreshold),
          receiveInviterNotification:
              settings.receiveInviterNotification ? 1 : 0,
          receiveEmailIntegrationNotification:
              settings.receiveEmailIntegrationNotification ? 1 : 0,
          walletCreated: settings.walletCreated ? 1 : 0,
          acceptTermsAndConditions: settings.acceptTermsAndConditions ? 1 : 0,
        ));
        final ProtonExchangeRate exchangeRate =
            await ExchangeRateService.getExchangeRate(fiatCurrency);
        updateExchangeRate(exchangeRate);
      }
      if (notify) {
        fiatCurrencyUpdateController.add(FiatCurrencyDataUpdated());
      }
    }
  }

  Future<void> updateReceiveEmailIntegrationNotification(isEnable) async {
    await settingsClient.receiveNotificationEmail(
        emailType: UserReceiveNotificationEmailTypes.emailIntegration,
        isEnable: isEnable);

    /// reload local db and cache
    await loadFromServer();
    settingsData = await _getFromDB();
  }

  Future<void> updateReceiveInviterNotification(isEnable) async {
    await settingsClient.receiveNotificationEmail(
        emailType: UserReceiveNotificationEmailTypes.notificationToInviter,
        isEnable: isEnable);

    /// reload local db and cache
    await loadFromServer();
    settingsData = await _getFromDB();
  }

  void updateExchangeRate(ProtonExchangeRate exchangeRate) {
    this.exchangeRate = exchangeRate;
    logger.d(
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
      receiveInviterNotification: settings.receiveInviterNotification == 1,
      receiveEmailIntegrationNotification:
          settings.receiveEmailIntegrationNotification == 1,
      walletCreated: settings.walletCreated == 1,
      acceptTermsAndConditions: settings.acceptTermsAndConditions == 1,
    ));
    settingsData = await _getFromDB();
    dataUpdateController.add(UserSettingDataUpdated());
  }

  String getFiatCurrencyName({FiatCurrency? fiatCurrency}) {
    fiatCurrency ??=
        settingsData?.fiatCurrency.toFiatCurrency() ?? FiatCurrency.usd;
    return fiatCurrency.name.toUpperCase();
  }

  String getFiatCurrencySign({FiatCurrency? fiatCurrency}) {
    fiatCurrency ??=
        settingsData?.fiatCurrency.toFiatCurrency() ?? FiatCurrency.usd;
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
    displayBalanceUpdateController.close();
  }
}

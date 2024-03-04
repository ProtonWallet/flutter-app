import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;

abstract class SettingsViewModel extends ViewModel {
  SettingsViewModel(super.coordinator);

  int selectedPage = 0;

  void updateSelected(int index);

  void getUserSettings();
  void updateBitcoinUnit(CommonBitcoinUnit symbol);
  void saveUserSettings();

  ApiUserSettings? userSettings;
  late TextEditingController bitcoinUnitController;
  late TextEditingController faitCurrencyController;
  late TextEditingController hideEmptyUsedAddressesController;
  late TextEditingController showWalletRecoveryController;
  late TextEditingController twoFactorAmountThresholdController;

  bool showWalletRecovery = false;
  bool hideEmptyUsedAddresses = false;

  @override
  bool get keepAlive => true;
}

class SettingsViewModelImpl extends SettingsViewModel {
  SettingsViewModelImpl(super.coordinator);

  final datasourceChangedStreamController =
      StreamController<SettingsViewModel>.broadcast();
  final selectedSectionChangedController = StreamController<int>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
    selectedSectionChangedController.close();
  }

  @override
  Future<void> loadData() async {
    bitcoinUnitController = TextEditingController();
    faitCurrencyController = TextEditingController();
    hideEmptyUsedAddressesController = TextEditingController();
    showWalletRecoveryController = TextEditingController();
    twoFactorAmountThresholdController = TextEditingController();
    getUserSettings();
    return;
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void updateSelected(int index) {
    selectedPage = index;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Future<void> getUserSettings() async {
    userSettings = await proton_api.getUserSettings();
    loadUserSettings();
  }

  void loadUserSettings(){
    if (userSettings != null) {
      bitcoinUnitController.text = userSettings!.bitcoinUnit.name.toUpperCase();
      faitCurrencyController.text =
          userSettings!.fiatCurrency.name.toUpperCase();
      showWalletRecovery = userSettings!.showWalletRecovery == 1;
      hideEmptyUsedAddresses = userSettings!.hideEmptyUsedAddresses == 1;
      int twoFactorAmountThreshold = userSettings!.twoFactorAmountThreshold ?? 1000;
      twoFactorAmountThresholdController.text = twoFactorAmountThreshold.toString();
    }
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Future<void> saveUserSettings() async {
    hideEmptyUsedAddresses = hideEmptyUsedAddressesController.text == "On";
    showWalletRecovery = showWalletRecoveryController.text == "On";
    int twoFactorAmountThreshold = int.parse(twoFactorAmountThresholdController.text);
    CommonBitcoinUnit bitcoinUnit;
    switch (bitcoinUnitController.text){
      case "BTC":
        bitcoinUnit = CommonBitcoinUnit.btc;
        break;
      case "MBTC":
        bitcoinUnit = CommonBitcoinUnit.mbtc;
        break;
      case "SAT":
        bitcoinUnit = CommonBitcoinUnit.sat;
        break;
      default:
        bitcoinUnit = CommonBitcoinUnit.sat;
        break;
    }

    ApiFiatCurrency fiatCurrency;
    switch (faitCurrencyController.text){
      case "USD":
        fiatCurrency = ApiFiatCurrency.usd;
        break;
      case "EUR":
        fiatCurrency = ApiFiatCurrency.eur;
        break;
      case "CHF":
        fiatCurrency = ApiFiatCurrency.chf;
        break;
      default:
        fiatCurrency = ApiFiatCurrency.usd;
        break;
    }

    userSettings = await proton_api.hideEmptyUsedAddresses(hideEmptyUsedAddresses: hideEmptyUsedAddresses);
    userSettings = await proton_api.twoFaThreshold(amount: twoFactorAmountThreshold);
    userSettings = await proton_api.bitcoinUnit(symbol: bitcoinUnit);
    userSettings = await proton_api.fiatCurrency(symbol: fiatCurrency);
    // userSettings = await proton_api.showWalletRecovery(showWalletRecovery: showWalletRecovery);

    loadUserSettings();
  }

  @override
  Future<void> updateBitcoinUnit(CommonBitcoinUnit symbol) async {
    userSettings = await proton_api.bitcoinUnit(symbol: symbol);
    datasourceChangedStreamController.sink.add(this);
  }
}

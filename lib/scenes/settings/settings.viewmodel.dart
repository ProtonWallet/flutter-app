import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/wallet_manager.dart';
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
  late TextEditingController twoFactorAmountThresholdController;

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
      hideEmptyUsedAddresses = userSettings!.hideEmptyUsedAddresses == 1;
      int twoFactorAmountThreshold = userSettings!.twoFactorAmountThreshold ?? 1000;
      twoFactorAmountThresholdController.text = twoFactorAmountThreshold.toString();
    }
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Future<void> saveUserSettings() async {
    hideEmptyUsedAddresses = hideEmptyUsedAddressesController.text == "On";
    int twoFactorAmountThreshold = int.parse(twoFactorAmountThresholdController.text);
    CommonBitcoinUnit bitcoinUnit = CommonHelper.getBitcoinUnit(bitcoinUnitController.text);
    ApiFiatCurrency fiatCurrency = CommonHelper.getFiatCurrency(faitCurrencyController.text);

    userSettings = await proton_api.hideEmptyUsedAddresses(hideEmptyUsedAddresses: hideEmptyUsedAddresses);
    userSettings = await proton_api.twoFaThreshold(amount: twoFactorAmountThreshold);
    userSettings = await proton_api.bitcoinUnit(symbol: bitcoinUnit);
    userSettings = await proton_api.fiatCurrency(symbol: fiatCurrency);

    loadUserSettings();
    await WalletManager.saveUserSetting(userSettings!);
  }

  @override
  Future<void> updateBitcoinUnit(CommonBitcoinUnit symbol) async {
    userSettings = await proton_api.bitcoinUnit(symbol: symbol);
    datasourceChangedStreamController.sink.add(this);
  }
}

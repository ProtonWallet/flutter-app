import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/user.settings.provider.dart';
import 'package:wallet/managers/secure.storage/secure.storage.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/services/exchange.rate.service.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/coordinator.dart';

class ProtonWalletProvider with ChangeNotifier {
  late ProtonWalletManager protonWallet;
  UserSettingProvider? userSettingProvider;

  ProtonWalletProvider() {
    var storage = SecureStorageManager(storage: SecureStorage()); // TODO: temp
    protonWallet = ProtonWalletManager(storage: storage);
  }

  Future<void> init() async {
    try {
      userSettingProvider = Provider.of<UserSettingProvider>(
          Coordinator.rootNavigatorKey.currentContext!,
          listen: false);
      await protonWallet.init();
      await setDefaultWallet();
    } catch (e) {
      logger.e(e.toString());
    }
  }

  void destroy() {
    protonWallet.destroy();
  }

  Future<void> updateFiatCurrencyInUserSettingProvider(
      FiatCurrency fiatCurrency) async {
    if (userSettingProvider != null) {
      userSettingProvider!.updateFiatCurrency(fiatCurrency);
      ProtonExchangeRate exchangeRate =
          await ExchangeRateService.getExchangeRate(fiatCurrency);
      userSettingProvider!.updateExchangeRate(exchangeRate);
      await setCurrentTransactions();
    }
  }

  Future<void> updateCurrentWalletName(String newName) async {
    await protonWallet.updateCurrentWalletName(newName);
    notifyListeners();
  }

  Future<void> setWallet(WalletModel walletModel) async {
    await protonWallet.setWallet(walletModel);
    FiatCurrency fiatCurrency =
        await WalletManager.getDefaultAccountFiatCurrency(
            protonWallet.currentWallet);
    await updateFiatCurrencyInUserSettingProvider(fiatCurrency);
    await setCurrentTransactions();
    syncWallet();
    await Future.delayed(const Duration(
        milliseconds: 100)); // wait for wallet sync refresh button
    logger.i("going to notifyListeners in setWallet();");
    notifyListeners();
  }

  Future<void> setWalletAccount(
      WalletModel walletModel, AccountModel accountModel) async {
    await protonWallet.setWalletAccount(walletModel, accountModel);
    FiatCurrency fiatCurrency =
        WalletManager.getAccountFiatCurrency(protonWallet.currentAccount);
    await updateFiatCurrencyInUserSettingProvider(fiatCurrency);
    await setCurrentTransactions();
    syncWallet();
    await Future.delayed(const Duration(
        milliseconds: 100)); // wait for wallet sync refresh button
    logger.i("going to notifyListeners in setWalletAccount();");
    notifyListeners();
  }

  Future<void> syncWallet() async {
    List<AccountModel> accountsToCheckTransaction = [];
    WalletModel? walletModel = protonWallet.currentWallet;
    if (protonWallet.currentAccount != null) {
      // wallet account view
      accountsToCheckTransaction.add(protonWallet.currentAccount!);
    } else {
      // wallet view
      await protonWallet.getCurrentWalletAccounts();
    }
    accountsToCheckTransaction = protonWallet.currentAccounts;

    for (AccountModel accountModel in accountsToCheckTransaction) {
      try {
        Wallet? wallet = await WalletManager.loadWalletWithID(
            walletModel!.id!, accountModel.id!);
        if (wallet != null) {
          protonWallet.syncWallet(wallet, walletModel, accountModel);
        }
      } catch (e) {
        logger.e(e.toString());
      }
    }
    notifyListeners();
  }

  Future<void> insertOrUpdateWallet(WalletModel walletModel) async {
    await protonWallet.insertOrUpdateWallet(walletModel);
    notifyListeners();
  }

  Future<void> deleteWallet(WalletModel deletedWalletModel) async {
    await protonWallet.deleteWallet(deletedWalletModel);
    notifyListeners();
  }

  Future<void> insertOrUpdateWalletAccount(AccountModel newAccountModel) async {
    await protonWallet.insertOrUpdateWalletAccount(newAccountModel);
    notifyListeners();
  }

  Future<void> deleteWalletAccount(AccountModel deletedAccountModel) async {
    await protonWallet.deleteWalletAccount(deletedAccountModel);
    notifyListeners();
  }

  Future<void> setCurrentTransactions() async {
    await protonWallet.setCurrentTransactions();
    notifyListeners();
  }

  Future<void> setPassphrase(WalletModel walletModel, String passphrase) async {
    await protonWallet.setPassphraseWithCheck(walletModel, passphrase);
    notifyListeners();
  }

  void applyHistoryTransactionFilterAndKeyword(String filter, String keyword) {
    protonWallet.applyHistoryTransactionFilterAndKeyword(filter, keyword);
    notifyListeners();
  }

  Future<void> setIntegratedEmailIDs(AccountModel accountModel) async {
    protonWallet.setIntegratedEmailIDs(accountModel);
    notifyListeners();
  }

  Future<void> setDefaultWallet() async {
    await protonWallet.setDefaultWallet();
    FiatCurrency fiatCurrency =
        await WalletManager.getDefaultAccountFiatCurrency(
            protonWallet.currentWallet);
    await updateFiatCurrencyInUserSettingProvider(fiatCurrency);
    notifyListeners();
  }

  String? getDisplayName() {
    String? name;
    if (protonWallet.currentWallet != null) {
      if (protonWallet.currentAccounts.length > 1 &&
          protonWallet.currentAccount != null) {
        return "${protonWallet.currentWallet!.name} - ${protonWallet.currentAccount!.labelDecrypt}";
      } else {
        return protonWallet.currentWallet!.name;
      }
    }
    return name;
  }
}

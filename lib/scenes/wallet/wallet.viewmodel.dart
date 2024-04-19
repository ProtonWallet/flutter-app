import 'dart:async';
import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:wallet/helper/local_toast.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/l10n/generated/locale.dart';
import 'package:wallet/scenes/wallet/wallet.coordinator.dart';

abstract class WalletViewModel extends ViewModel<WalletCoordinator> {
  List accounts = [];
  int walletID;
  bool initialed = false;
  late WalletModel walletModel;
  late AccountModel accountModel;

  late ValueNotifier valueNotifier;

  void copyMnemonic(BuildContext context);

  void initAccount();

  void updateAccount(AccountModel accountModel);

  void updateWalletInfo();

  void syncWallet();

  Future<void> deleteAccount();

  Future<void> updateAccountLabel(String newLabel);

  WalletViewModel(super.coordinator, this.walletID);

  int totalBalance = 0;
  int balance = 0;
  int unconfirmed = 0;
  int confirmed = 0;
  bool isSyncing = false;
  SecretKey? secretKey;
}

class WalletViewModelImpl extends WalletViewModel {
  WalletViewModelImpl(super.coordinator, super.walletID);

  final BdkLibrary _lib = BdkLibrary();
  Blockchain? blockchain;
  late Wallet wallet;
  final datasourceChangedStreamController =
      StreamController<WalletViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    blockchain ??= await _lib.initializeBlockchain(false);
    walletModel = await DBHelper.walletDao!.findById(walletID);
    accounts = await DBHelper.accountDao!.findAllByWalletID(walletID);
    accountModel = accounts.first;
    await initAccount();
    wallet = await WalletManager.loadWalletWithID(walletID, accountModel.id!);
    secretKey = await WalletManager.getWalletKey(walletModel.serverWalletID);
    valueNotifier = ValueNotifier(accountModel);
    valueNotifier.addListener(() {
      updateAccount(valueNotifier.value);
    });
    updateWalletInfo();
    initialed = true;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> updateAccount(AccountModel accountModel) async {
    if (accountModel.id != this.accountModel.id) {
      this.accountModel = accountModel;
      initAccount();
    }
  }

  @override
  Future<void> initAccount() async {
    wallet = await WalletManager.loadWalletWithID(walletID, accountModel.id!);
    var walletBalance = await wallet.getBalance();
    balance = walletBalance.total;
    var unconfirmedList = await _lib.getUnConfirmedTransactions(wallet);
    unconfirmed = unconfirmedList.length;

    var confirmedList = await _lib.getConfirmedTransactions(wallet);
    confirmed = confirmedList.length;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Future<void> copyMnemonic(BuildContext context) async {
    Clipboard.setData(ClipboardData(
            text: await WalletManager.getMnemonicWithID(walletID)))
        .then((_) {
      LocalToast.showToast(context, S.of(context).copied_mnemonic);
    });
  }

  @override
  Future<void> updateAccountLabel(String newLabel) async {
    try {
      WalletAccount _ = await proton_api.updateWalletAccountLabel(
          walletId: walletModel.serverWalletID,
          walletAccountId: accountModel.serverAccountID,
          newLabel: await WalletKeyHelper.encrypt(secretKey!, newLabel));
      accountModel.label =
          base64Decode(await WalletKeyHelper.encrypt(secretKey!, newLabel));
      accountModel.labelDecrypt = newLabel;
      await DBHelper.accountDao!.update(accountModel);
      await loadData();
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await proton_api.deleteWalletAccount(
          walletId: walletModel.serverWalletID,
          walletAccountId: accountModel.serverAccountID);
      await DBHelper.accountDao!.delete(accountModel.id!);
      await loadData();
    } catch (e) {
      logger.e(e);
    }
  }

  @override
  Future<void> syncWallet() async {
    if (initialed && !isSyncing) {
      isSyncing = true;
      datasourceChangedStreamController.sink.add(this);
      await _lib.sync(blockchain!, wallet);
      var walletBalance = await wallet.getBalance();
      balance = walletBalance.total;
      var unconfirmedList = await _lib.getUnConfirmedTransactions(wallet);
      unconfirmed = unconfirmedList.length;

      var confirmedList = await _lib.getConfirmedTransactions(wallet);
      confirmed = confirmedList.length;
      isSyncing = false;
      datasourceChangedStreamController.sink.add(this);
      updateWalletInfo();
    }
  }

  @override
  Future<void> updateWalletInfo() async {
    totalBalance = 0;
    for (AccountModel accountModel in accounts) {
      Wallet wallet =
          await WalletManager.loadWalletWithID(walletID, accountModel.id!);
      totalBalance += (await wallet.getBalance()).total;
      datasourceChangedStreamController.sink.add(this);
    }
  }

  @override
  void move(NavigationIdentifier to) {
    switch (to) {
      case ViewIdentifiers.send:
        coordinator.showSend(accountModel.walletID, accountModel.id ?? 0);
        break;
      case ViewIdentifiers.receive:
        coordinator.showReceive(accountModel.walletID, accountModel.id ?? 0);
        break;
      case ViewIdentifiers.history:
        coordinator.showHistory(accountModel.walletID, accountModel.id ?? 0, FiatCurrency.usd);
        break;
      case ViewIdentifiers.walletDeletion:
        coordinator.showDeletion(accountModel.walletID);
        break;
    }
  }
}

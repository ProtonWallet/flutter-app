import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/cupertino.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/event_loop_helper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/helper/wallet_manager.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';

abstract class HomeViewModel extends ViewModel {
  HomeViewModel(super.coordinator);

  int selectedPage = 0;
  int selectedWalletID = 0;
  double totalBalance = 0.0;
  String selectedAccountDerivationPath = WalletManager.getDerivationPath();

  void updateSelected(int index);

  List userWallets = [];
  bool hasWallet = true;
  bool hasMailIntegration = false;
  bool isFetching = false;

  void checkNewWallet();

  void updateWallets();

  void updateHasMailIntegration(bool later);

  void setOnBoard(BuildContext context);

  void fetchWallets();

  void setSelectedWallet(int walletID);

  int unconfirmed = 0;
  int totalAccount = 0;
  int confirmed = 0;

  @override
  bool get keepAlive => true;
  bool forceReloadWallet = false;
}

class HomeViewModelImpl extends HomeViewModel {
  HomeViewModelImpl(super.coordinator);

  final datasourceChangedStreamController =
      StreamController<HomeViewModel>.broadcast();
  final selectedSectionChangedController = StreamController<int>.broadcast();

  final BdkLibrary _lib = BdkLibrary();
  Blockchain? blockchain;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
    selectedSectionChangedController.close();
    //clean up wallet ....
  }

  @override
  Future<void> loadData() async {
    await proton_api.initApiService(
        userName: 'ProtonWallet', password: 'alicebob');
    EventLoopHelper.start();
    blockchain ??= await _lib.initializeBlockchain(false);
    hasWallet = await WalletManager.hasAccount();
    datasourceChangedStreamController.sink.add(this);
    checkNewWallet();
    // fetchWallets();
  }

  @override
  Future<void> checkNewWallet() async {
    int totalAccount_ = 0;
    await DBHelper.walletDao!.findAll().then((results) async {
      for (WalletModel walletModel in results) {
        walletModel.accountCount =
            await DBHelper.accountDao!.getAccountCount(walletModel.id!);
        totalAccount_ += walletModel.accountCount;
      }
      if (results.length != userWallets.length ||
          totalAccount != totalAccount_ || forceReloadWallet) {
        userWallets = results;
        totalAccount = totalAccount_;
        forceReloadWallet = false;
      }
    });
    datasourceChangedStreamController.sink.add(this);
    updateWallets();
    Future.delayed(const Duration(milliseconds: 1000), () {
      checkNewWallet();
    });
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
  void updateHasMailIntegration(bool later) {
    hasMailIntegration = later;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  void setOnBoard(BuildContext context) {
    hasWallet = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      coordinator.move(ViewIdentifiers.setupOnboard, context);
      datasourceChangedStreamController.sink.add(this);
    });
  }

  @override
  Future<void> updateWallets() async {
    if (isFetching) {
      return;
    }
    double totalBalance = 0.0;
    for (WalletModel walletModel in userWallets) {
      walletModel.balance =
          await WalletManager.getWalletBalance(walletModel.id!);
      totalBalance += walletModel.balance;
    }
    this.totalBalance = totalBalance;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Future<void> fetchWallets() async {
    isFetching = true;
    // var authInfo = await fetchAuthInfo(userName: 'ProtonWallet');
    List<WalletData> wallets = await proton_api.getWallets();
    for (WalletData walletData in wallets.reversed) {
      WalletModel? walletModel =
          await DBHelper.walletDao!.getWalletByServerWalletID(walletData.wallet.id);
      String userPrivateKey = await SecureStorageHelper.get("userPrivateKey");
      String userKeyID = await SecureStorageHelper.get("userKeyID");
      String userPassphrase = await SecureStorageHelper.get("userPassphrase");
      if (userKeyID != walletData.walletKey.userKeyId) {
        logger.i(
            "Wallet Key mismatch: \nuserKeyID from login response:$userKeyID\nuserKeyID from API response:${walletData.walletKey.userKeyId}");
      }
      String encodedEncryptedEntropy = "";
      Uint8List entropy = Uint8List(0);
      try {
        encodedEncryptedEntropy = walletData.walletKey.walletKey;
        entropy = proton_crypto.decryptBinary(userPrivateKey, userPassphrase,
            base64Decode(encodedEncryptedEntropy));
      } catch (e) {
        logger.i(e.toString());
      }
      SecretKey secretKey =
          WalletKeyHelper.restoreSecretKeyFromEntropy(entropy);
      if (walletModel == null) {
        DateTime now = DateTime.now();
        WalletModel wallet = WalletModel(
            id: null,
            userID: 0,
            name: walletData.wallet.name,
            mnemonic: base64Decode(walletData.wallet.mnemonic!),
            passphrase: walletData.wallet.hasPassphrase,
            publicKey: Uint8List(0),
            imported: walletData.wallet.isImported,
            priority: walletData.wallet.priority,
            status: entropy.isNotEmpty
                ? walletData.wallet.status
                : WalletModel.statusDisabled,
            type: walletData.wallet.type,
            fingerprint: walletData.wallet.fingerprint,
            createTime: now.millisecondsSinceEpoch ~/ 1000,
            modifyTime: now.millisecondsSinceEpoch ~/ 1000,
            serverWalletID: walletData.wallet.id);
        int walletID = await DBHelper.walletDao!.insert(wallet);
        if (entropy.isNotEmpty) {
          await WalletManager.setWalletKey(walletID,
              secretKey); // need to set key first, so that we can decrypt for walletAccount
          List<WalletAccount> walletAccounts = await proton_api
              .getWalletAccounts(walletId: walletData.wallet.id);
          if (walletAccounts.isNotEmpty) {
            for (WalletAccount walletAccount in walletAccounts) {
              WalletManager.insertOrUpdateAccount(
                  walletID,
                  walletAccount.label,
                  walletAccount.scriptType,
                  "${walletAccount.derivationPath}/0",
                  walletAccount.id);
            }
          }
        }
      } else {
        if (entropy.isNotEmpty) {
          List<String> existingAccountIDs = [];
          List<WalletAccount> walletAccounts = await proton_api
              .getWalletAccounts(walletId: walletData.wallet.id);
          if (walletAccounts.isNotEmpty) {
            for (WalletAccount walletAccount in walletAccounts) {
              existingAccountIDs.add(walletAccount.id);
              WalletManager.insertOrUpdateAccount(
                  walletModel.id!,
                  walletAccount.label,
                  walletAccount.scriptType,
                  "${walletAccount.derivationPath}/0",
                  walletAccount.id);
            }
          }
          try {
            if (walletModel.accountCount != walletAccounts.length) {
              DBHelper.accountDao!.deleteAccountsNotInServers(
                  walletModel.id!, existingAccountIDs);
            }
          } catch (e) {
            e.toString();
          }
        } else {
          walletModel.status = WalletModel.statusDisabled;
          DBHelper.walletDao!.update(walletModel);
        }
      }
    }
    isFetching = false;
    Future.delayed(const Duration(seconds: 30), () {
      fetchWallets();
    });
  }

  @override
  void setSelectedWallet(int walletID) {
    selectedWalletID = walletID;
  }
}

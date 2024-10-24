import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/models/wallet.passphrase.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/rust/common/errors.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/passphrase/passphrase.coordinator.dart';

abstract class PassphraseViewModel extends ViewModel<PassphraseCoordinator> {
  final WalletManager walletManager;
  final DataProviderManager dataProviderManager;
  final WalletMenuModel walletMenuModel;

  late FocusNode walletRecoverPassphraseFocusNode;
  late TextEditingController walletRecoverPassphraseController;
  bool isWalletPassphraseMatch = true;
  String errorMessage = "";

  Future<bool> checkFingerprint(String passphrase);

  Future<void> savePassphrase(String passphrase);

  PassphraseViewModel(
    super.coordinator,
    this.walletManager,
    this.dataProviderManager,
    this.walletMenuModel,
  );
}

class PassphraseViewModelImpl extends PassphraseViewModel {
  PassphraseViewModelImpl(
    super.coordinator,
    super.walletManager,
    super.dataProviderManager,
    super.walletMenuModel,
  );

  @override
  Future<void> loadData() async {
    /// init UI controller and focusNode
    walletRecoverPassphraseFocusNode = FocusNode();
    walletRecoverPassphraseController = TextEditingController(text: "");

    /// request focus
    walletRecoverPassphraseFocusNode.requestFocus();
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  Future<bool> checkFingerprint(
    String passphrase,
  ) async {
    isWalletPassphraseMatch = await walletManager.checkFingerprint(
      walletMenuModel.walletModel,
      passphrase,
    );

    sinkAddSafe();
    return isWalletPassphraseMatch;
  }

  @override
  Future<void> savePassphrase(String passphrase) async {
    errorMessage = "";
    try {
      await dataProviderManager.walletPassphraseProvider.saveWalletPassphrase(
        WalletPassphrase(
          walletID: walletMenuModel.walletModel.walletID,
          passphrase: passphrase,
        ),
      );
    } on BridgeError catch (e, stacktrace) {
      errorMessage = parseSampleDisplayError(e);
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    } else {
      /// no error when saving passphrase, update status
      walletMenuModel.hasValidPassword =
          true; // pass walletMenuModel by reference, so we will also update the hasValidPassword status for wallet list item in homepage
      for (AccountMenuModel accountMenuModel in walletMenuModel.accounts) {
        dataProviderManager.bdkTransactionDataProvider.syncWallet(
          walletMenuModel.walletModel,
          accountMenuModel.accountModel,
          forceSync: true,
          heightChanged: false,
        );
      }
    }
  }
}

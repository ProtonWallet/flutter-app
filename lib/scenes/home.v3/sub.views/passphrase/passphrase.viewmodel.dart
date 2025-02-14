import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/providers/bdk.transaction.data.provider.dart';
import 'package:wallet/managers/providers/models/wallet.passphrase.dart';
import 'package:wallet/managers/providers/wallet.passphrase.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/passphrase/passphrase.coordinator.dart';

abstract class PassphraseViewModel extends ViewModel<PassphraseCoordinator> {
  late FocusNode walletRecoverPassphraseFocusNode;
  late TextEditingController walletRecoverPassphraseController;
  bool isWalletPassphraseMatch = true;
  String errorMessage = "";

  Future<bool> checkFingerprint(String passphrase);

  Future<void> savePassphrase(String passphrase);

  String get walletName;

  PassphraseViewModel(
    super.coordinator,
  );
}

class PassphraseViewModelImpl extends PassphraseViewModel {
  final WalletManager walletManager;
  final WalletMenuModel walletMenuModel;
  final AppStateManager appStateManager;

  /// data providers
  final WalletPassphraseProvider walletPassphraseProvider;
  final BDKTransactionDataProvider bdkTransactionDataProvider;

  PassphraseViewModelImpl(
    super.coordinator,
    this.walletManager,
    this.appStateManager,
    this.walletMenuModel,
    this.walletPassphraseProvider,
    this.bdkTransactionDataProvider,
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
      await walletPassphraseProvider.saveWalletPassphrase(
        WalletPassphrase(
          walletID: walletMenuModel.walletModel.walletID,
          passphrase: passphrase,
        ),
      );
    } on BridgeError catch (e, stacktrace) {
      if (!appStateManager.updateStateFrom(e)) {
        errorMessage = parseMuonError(e) ?? parseSampleDisplayError(e);
      }
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
    } else {
      /// no error when saving passphrase, update status
      /// since we pass walletMenuModel by reference, this operation
      /// will also update the hasValidPassword status for wallet list item in homepage
      walletMenuModel.hasValidPassword = true;
      for (AccountMenuModel accountMenuModel in walletMenuModel.accounts) {
        bdkTransactionDataProvider.syncWallet(
          walletMenuModel.walletModel,
          accountMenuModel.accountModel,
          forceSync: true,
          heightChanged: false,
        );
      }
    }
  }

  @override
  String get walletName => walletMenuModel.walletName;
}

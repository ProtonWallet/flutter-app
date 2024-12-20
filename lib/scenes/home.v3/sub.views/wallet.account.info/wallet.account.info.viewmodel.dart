import 'dart:async';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/rust/common/keychain_kind.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.info/wallet.account.info.coordinator.dart';

abstract class WalletAccountInfoViewModel
    extends ViewModel<WalletAccountInfoCoordinator> {
  final AccountMenuModel accountMenuModel;

  WalletAccountInfoViewModel(
    this.accountMenuModel,
    super.coordinator,
  );

  /// variables expose for UI
  int accountLastUsedIndex = -1;
  int accountPriority = -1;
  int accountHighestIndexFromBlockchain = -1;
  int accountPoolSize = -1;
  String accountName = "";
  String accountDerivationPath = "";
}

class WalletAccountInfoViewModelImpl extends WalletAccountInfoViewModel {
  WalletAccountInfoViewModelImpl(
    super.accountMenuModel,
    super.coordinator,
    this.walletManager,
  );

  /// wallet manager
  final WalletManager walletManager;

  @override
  Future<void> loadData() async {
    /// load account basic info
    accountLastUsedIndex = accountMenuModel.accountModel.lastUsedIndex;
    accountPoolSize = accountMenuModel.accountModel.poolSize;
    accountPriority = accountMenuModel.accountModel.priority;
    accountName = accountMenuModel.label;
    accountDerivationPath = accountMenuModel.accountModel.derivationPath;

    /// load highestIndexFromBlockchain
    final frbAccount = (await walletManager.loadWalletWithID(
      accountMenuModel.accountModel.walletID,
      accountMenuModel.accountModel.accountID,
      serverScriptType: accountMenuModel.accountModel.scriptType,
    ))!;
    accountHighestIndexFromBlockchain =
        await frbAccount.getHighestUsedAddressIndexInOutput(
                keychain: KeychainKind.external_) ??
            -1;
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}

import 'dart:async';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/features/wallet/delete.wallet.bloc.dart';
import 'package:wallet/rust/common/errors.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/delete.wallet.account/delete.wallet.account.coordinator.dart';

abstract class DeleteWalletAccountViewModel
    extends ViewModel<DeleteWalletAccountCoordinator> {
  final AccountMenuModel accountMenuModel;

  DeleteWalletAccountViewModel(
    this.accountMenuModel,
    super.coordinator,
  );

  Future<bool> deleteWalletAccount();

  String errorMessage = "";

  bool isDeleting = false;
}

class DeleteWalletAccountViewModelImpl extends DeleteWalletAccountViewModel {
  final AppStateManager appStateManager;
  final DeleteWalletBloc deleteWalletBloc;

  DeleteWalletAccountViewModelImpl(
    this.appStateManager,
    this.deleteWalletBloc,
    super.accountMenuModel,
    super.coordinator,
  );

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  Future<bool> deleteWalletAccount() async {
    if (appStateManager.isHomeInitialed) {
      try {
        await deleteWalletBloc.deleteWalletAccount(
          accountMenuModel.accountModel.walletID,
          accountMenuModel.accountModel.accountID,
        );
      } on BridgeError catch (e, stacktrace) {
        errorMessage = parseSampleDisplayError(e);
        logger.e("importWallet BridgeError: $e, stacktrace: $stacktrace");
      } catch (e, stacktrace) {
        logger.e("importWallet error: $e, stacktrace: $stacktrace");
        errorMessage = e.toString();
      }
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
      return false;
    }
    return true;
  }
}

import 'dart:async';
import 'package:collection/collection.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/features/wallet/delete.wallet.bloc.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/delete.wallet/delete.wallet.coordinator.dart';

abstract class DeleteWalletViewModel
    extends ViewModel<DeleteWalletCoordinator> {
  final DeleteWalletBloc deleteWalletBloc;
  final WalletMenuModel walletMenuModel;
  final bool triggerFromSidebar;
  bool hasBalance = false;

  DeleteWalletViewModel(
    this.deleteWalletBloc,
    this.walletMenuModel,
    super.coordinator, {
    required this.triggerFromSidebar,
  });

  void deleteWalletAuth(String pwd, String twofa) {
    deleteWalletBloc.add(DeleteWalletEvent(
      walletMenuModel.walletModel,
      DeleteWalletSteps.auth,
      password: pwd,
      twofa: twofa,
    ));
  }

  void deleteWallet() {
    deleteWalletBloc.add(DeleteWalletEvent(
      walletMenuModel.walletModel,
      DeleteWalletSteps.start,
    ));
  }

  String errorMessage = "";

  bool isDeleting = false;

  void showSetupBackup() {
    coordinator.showSetupBackup();
  }
}

class DeleteWalletViewModelImpl extends DeleteWalletViewModel {
  final AppStateManager appStateManager;

  DeleteWalletViewModelImpl(
    this.appStateManager,
    super.deleteWalletBloc,
    super.walletMenuModel,
    super.coordinator, {
    required super.triggerFromSidebar,
  });

  @override
  Future<void> loadData() async {
    hasBalance = walletMenuModel.accounts.map((v) => v.balance).sum > 0;
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}

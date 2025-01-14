import 'package:flutter/material.dart';
import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet.balance/wallet.balance.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/features/wallet/wallet.name.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/scenes/backup.seed/backup.coordinator.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/add.wallet.account/add.wallet.account.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/bve.privacy/bve.privacy.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/delete.wallet/delete.wallet.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/edit.bve/edit.bve.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.setting/wallet.account.setting.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.setting/wallet.setting.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.setting/wallet.setting.viewmodel.dart';

class WalletSettingCoordinator extends Coordinator {
  late ViewBase widget;
  final WalletListBloc walletListBloc;
  final WalletBalanceBloc walletBalanceBloc;
  final WalletNameBloc walletNameBloc;

  final WalletMenuModel walletMenuModel;

  WalletSettingCoordinator(
    this.walletListBloc,
    this.walletBalanceBloc,
    this.walletNameBloc,
    this.walletMenuModel,
  );

  void showWalletAccountSetting(AccountMenuModel accountMenuModel) {
    final view = WalletAccountSettingCoordinator(accountMenuModel).start();
    showInBottomSheet(view);
  }

  void showSetupBackup() {
    final view =
        SetupBackupCoordinator(walletMenuModel.walletModel.walletID).start();
    showInBottomSheet(
      view,
      backgroundColor: ProtonColors.white,
    );
  }

  void showEditBvE(
    WalletListBloc walletListBloc,
    AccountModel accountModel,
    VoidCallback? callback,
  ) {
    final view = EditBvECoordinator(
      walletListBloc,
      walletMenuModel.walletModel,
      accountModel,
      callback,
    ).start();
    showInBottomSheet(view);
  }

  void showAddWalletAccount() {
    final view = AddWalletAccountCoordinator(
      walletMenuModel.walletModel.walletID,
    ).start();
    showInBottomSheet(
      view,
      backgroundColor: ProtonColors.white,
    );
  }

  void showBvEPrivacy({
    required bool isPrimaryAccount,
  }) {
    showInBottomSheet(
      BvEPrivacyCoordinator(isPrimaryAccount: isPrimaryAccount).start(),
      backgroundColor: ProtonColors.white,
    );
  }

  void showDeleteWallet({
    required bool triggerFromSidebar,
  }) {
    final view = DeleteWalletCoordinator(
      walletMenuModel,
      triggerFromSidebar: triggerFromSidebar,
    ).start();
    showInBottomSheet(view);
  }

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final walletManager = serviceManager.get<WalletManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final appStateManager = serviceManager.get<AppStateManager>();
    final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();

    final viewModel = WalletSettingViewModelImpl(
      this,
      walletListBloc,
      walletBalanceBloc,
      walletNameBloc,
      walletMenuModel,
      walletManager,
      appStateManager,
      dataProviderManager.userSettingsDataProvider,
      dataProviderManager.addressKeyProvider,
      apiServiceManager.getSettingsClient(),
      apiServiceManager.getWalletClient(),
    );
    widget = WalletSettingView(
      viewModel,
    );
    return widget;
  }
}

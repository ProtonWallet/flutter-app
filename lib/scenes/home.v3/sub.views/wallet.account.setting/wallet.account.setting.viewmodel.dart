import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/providers/unleash.data.provider.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.setting/wallet.account.setting.coordinator.dart';

abstract class WalletAccountSettingViewModel
    extends ViewModel<WalletAccountSettingCoordinator> {
  final AccountMenuModel accountMenuModel;

  WalletAccountSettingViewModel(
    this.accountMenuModel,
    super.coordinator,
  );

  String errorMessage = "";

  bool isMobileClientDebugMode();
}

class WalletAccountSettingViewModelImpl extends WalletAccountSettingViewModel {
  WalletAccountSettingViewModelImpl(
    super.accountMenuModel,
    super.coordinator,
    this.unleashDataProvider,
  );

  final UnleashDataProvider unleashDataProvider;

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.deleteWalletAccount:
        coordinator.showDeleteWalletAccount();
      case NavID.walletAccountAddressList:
        coordinator.showWalletAccountAddressList();
      case NavID.walletAccountInfo:
        coordinator.showWalletAccountInfo();
      default:
        break;
    }
  }

  @override
  bool isMobileClientDebugMode() {
    return unleashDataProvider.isMobileClientDebugMode() || kDebugMode;
  }
}

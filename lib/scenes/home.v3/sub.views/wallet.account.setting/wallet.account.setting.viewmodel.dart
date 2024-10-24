import 'dart:async';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
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
}

class WalletAccountSettingViewModelImpl extends WalletAccountSettingViewModel {
  WalletAccountSettingViewModelImpl(
    super.accountMenuModel,
    super.coordinator,
  );

  @override
  Future<void> loadData() async {
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}

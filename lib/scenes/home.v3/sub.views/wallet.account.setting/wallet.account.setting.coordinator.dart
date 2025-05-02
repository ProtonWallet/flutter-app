import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/delete.wallet.account/delete.wallet.account.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.address.list/wallet.account.address.list.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.info/wallet.account.info.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.setting/wallet.account.setting.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.setting/wallet.account.setting.viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.statement.export/wallet.account.statement.export.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.xpub.info/wallet.account.xpub.info.coordinator.dart';

class WalletAccountSettingCoordinator extends Coordinator {
  late ViewBase widget;
  final AccountMenuModel accountMenuModel;

  WalletAccountSettingCoordinator(
    this.accountMenuModel,
  );

  void showDeleteWalletAccount() {
    final view = DeleteWalletAccountCoordinator(accountMenuModel).start();
    showInBottomSheet(view);
  }

  void showWalletAccountAddressList() {
    final view = WalletAccountAddressListCoordinator(accountMenuModel).start();
    showInBottomSheet(view);
  }

  void showWalletAccountInfo() {
    final view = WalletAccountInfoCoordinator(accountMenuModel).start();
    showInBottomSheet(view);
  }

  void showWalletAccountXpubInfo() {
    final view =
        WalletAccountXpubInfoCoodinator(accountMenuModel.accountModel).start();
    showInBottomSheet(view);
  }

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final viewModel = WalletAccountSettingViewModelImpl(
      accountMenuModel,
      this,
      dataProviderManager.unleashDataProvider,
    );
    widget = WalletAccountSettingView(
      viewModel,
    );
    return widget;
  }
}

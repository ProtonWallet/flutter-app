import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/history/details.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.address.list/wallet.account.address.list.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.address.list/wallet.account.address.list.viewmodel.dart';

class WalletAccountAddressListCoordinator extends Coordinator {
  late ViewBase widget;
  final AccountMenuModel accountMenuModel;

  WalletAccountAddressListCoordinator(
    this.accountMenuModel,
  );

  void showHistoryDetails(
    String walletID,
    String accountID,
    FrbTransactionDetails frbTransactionDetails,
  ) {
    final view = HistoryDetailCoordinator(
      walletID,
      accountID,
      frbTransactionDetails,
    ).start();
    showInBottomSheet(
      view,
      backgroundColor: ProtonColors.white,
    );
  }

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final walletManager = serviceManager.get<WalletManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();

    final viewModel = WalletAccountAddressListViewModelImpl(
      this,
      walletManager,
      dataProviderManager.userSettingsDataProvider,
      accountMenuModel,
    );
    widget = WalletAccountAddressListView(
      viewModel,
    );
    return widget;
  }
}

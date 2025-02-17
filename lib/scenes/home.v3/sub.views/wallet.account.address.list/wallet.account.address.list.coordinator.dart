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
import 'package:wallet/scenes/qrcode.content/qrcode.content.coordinator.dart';
import 'package:wallet/scenes/qrcode.content/qrcode.content.viewmodel.dart';

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
      backgroundColor: ProtonColors.backgroundSecondary,
    );
  }

  void showAddressQRcode(String address) {
    final view = QRcodeContentCoordinator(
      QRcodeType.bitcoinAddress,
      address,
    ).start();
    showInBottomSheet(
      view,
      backgroundColor: ProtonColors.backgroundSecondary,
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
      dataProviderManager.poolAddressDataProvider,
      accountMenuModel,
    );
    widget = WalletAccountAddressListView(
      viewModel,
    );
    return widget;
  }
}

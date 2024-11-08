import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/history/details.view.dart';
import 'package:wallet/scenes/history/details.viewmodel.dart';

class HistoryDetailCoordinator extends Coordinator {
  late ViewBase widget;
  final FrbTransactionDetails frbTransactionDetails;
  final String walletID;
  final String accountID;

  HistoryDetailCoordinator(
    this.walletID,
    this.accountID,
    this.frbTransactionDetails,
  );

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final userManager = serviceManager.get<UserManager>();
    final walletManager = serviceManager.get<WalletManager>();
    final serverTransactionDataProvider =
        serviceManager.get<DataProviderManager>().serverTransactionDataProvider;
    final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();

    final viewModel = HistoryDetailViewModelImpl(
      this,
      walletID,
      accountID,
      frbTransactionDetails,
      userManager,
      walletManager,
      serverTransactionDataProvider,
      apiServiceManager.getApiService().getWalletClient(),
      dataProviderManager.walletKeysProvider,
      dataProviderManager.userSettingsDataProvider,
      dataProviderManager.contactsDataProvider,
      dataProviderManager.walletNameProvider,
      dataProviderManager.addressKeyProvider,
    );
    widget = HistoryDetailView(
      viewModel,
    );
    return widget;
  }
}

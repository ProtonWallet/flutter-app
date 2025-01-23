import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/transaction.info.model.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/history/details.view.dart';
import 'package:wallet/scenes/history/details.viewmodel.dart';
import 'package:wallet/scenes/rbf/rbf.coordinator.dart';

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

  void showRBF(
    ProtonExchangeRate exchangeRate,
    TransactionModel transactionModel,
    String addressID,
    List<TransactionInfoModel> recipients,
  ) {
    final view = RbfCoordinator(
      frbTransactionDetails,
      transactionModel,
      exchangeRate,
      walletID,
      accountID,
      addressID,
      recipients,
    ).start();
    showInBottomSheet(view);
  }

  @override
  ViewBase<ViewModel> start() {
    final userManager = serviceManager.get<UserManager>();
    final walletManager = serviceManager.get<WalletManager>();
    final appStateManager = serviceManager.get<AppStateManager>();
    final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();

    final viewModel = HistoryDetailViewModelImpl(
      this,
      walletID,
      accountID,
      frbTransactionDetails,
      userManager,
      walletManager,
      appStateManager,
      dataProviderManager.serverTransactionDataProvider,
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

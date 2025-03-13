import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/transaction.info.model.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/rust/api/bdk_wallet/transaction_details.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/logs/logs.coordinator.dart';
import 'package:wallet/scenes/rbf/rbf.view.dart';
import 'package:wallet/scenes/rbf/rbf.viewmodel.dart';

class RbfCoordinator extends Coordinator {
  late ViewBase widget;
  final FrbTransactionDetails frbTransactionDetails;
  final TransactionModel transactionModel;
  final ProtonExchangeRate exchangeRate;
  final String walletID;
  final String accountID;
  final String addressID;
  final List<TransactionInfoModel> recipients;

  RbfCoordinator(
    this.frbTransactionDetails,
    this.transactionModel,
    this.exchangeRate,
    this.walletID,
    this.accountID,
    this.addressID,
    this.recipients,
  );

  @override
  void end() {}

  void showLogs() {
    final view = LogsCoordinator().start();
    push(view);
  }

  @override
  ViewBase<ViewModel> start() {
    final walletManager = serviceManager.get<WalletManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final apiManager = serviceManager.get<ProtonApiServiceManager>();
    final eventLoop = serviceManager.get<EventLoop>();
    final viewModel = RbfViewModelImpl(
      this,
      walletManager,
      eventLoop,
      dataProviderManager.userSettingsDataProvider,
      dataProviderManager.addressKeyProvider,
      dataProviderManager.bdkTransactionDataProvider,
      apiManager.getTransactionClient(),
      frbTransactionDetails,
      transactionModel,
      exchangeRate,
      walletID,
      accountID,
      addressID,
      recipients,
      apiManager.getApiService().getBlockchainClient(),
    );
    widget = RbfView(
      viewModel,
    );
    return widget;
  }
}

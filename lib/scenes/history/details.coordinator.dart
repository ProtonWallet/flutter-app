import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/history/details.view.dart';
import 'package:wallet/scenes/history/details.viewmodel.dart';

class HistoryDetailCoordinator extends Coordinator {
  late ViewBase widget;
  final String walletID;
  final String accountID;
  final String txID;
  final FiatCurrency userFiatCurrency;

  HistoryDetailCoordinator(
    this.walletID,
    this.accountID,
    this.txID,
    this.userFiatCurrency,
  );

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final userManager = serviceManager.get<UserManager>();
    final serverTransactionDataProvider =
        serviceManager.get<DataProviderManager>().serverTransactionDataProvider;
    final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final viewModel = HistoryDetailViewModelImpl(
      this,
      walletID,
      accountID,
      txID,
      userFiatCurrency,
      userManager,
      serverTransactionDataProvider,
      apiServiceManager.getApiService().getWalletClient(),
      dataProviderManager.walletKeysProvider,
      dataProviderManager.userSettingsDataProvider,
      dataProviderManager.contactsDataProvider,
    );
    widget = HistoryDetailView(
      viewModel,
    );
    return widget;
  }
}

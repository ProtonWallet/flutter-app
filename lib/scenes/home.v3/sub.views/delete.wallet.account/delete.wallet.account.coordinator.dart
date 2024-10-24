import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/features/wallet/delete.wallet.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/delete.wallet.account/delete.wallet.account.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/delete.wallet.account/delete.wallet.account.viewmodel.dart';

class DeleteWalletAccountCoordinator extends Coordinator {
  late ViewBase widget;
  final AccountMenuModel accountMenuModel;

  DeleteWalletAccountCoordinator(
    this.accountMenuModel,
  );

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final appStateManager = serviceManager.get<AppStateManager>();
    final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();

    /// build delete wallet feature bloc
    final deleteWalletBloc = DeleteWalletBloc(
        dataProviderManager.walletDataProvider,
        apiServiceManager.getWalletClient(),
        apiServiceManager.getProtonUsersApiClient());

    final viewModel = DeleteWalletAccountViewModelImpl(
      appStateManager,
      deleteWalletBloc,
      accountMenuModel,
      this,
    );
    widget = DeleteWalletAccountView(
      viewModel,
    );
    return widget;
  }
}

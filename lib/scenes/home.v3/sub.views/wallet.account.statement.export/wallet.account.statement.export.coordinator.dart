import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.statement.export/wallet.account.statement.export.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.statement.export/wallet.account.statement.export.viewmodel.dart';

class WalletAccountStatementExportCoordinator extends Coordinator {
  late ViewBase widget;
  final WalletListBloc walletListBloc;
  final AccountMenuModel accountMenuModel;

  WalletAccountStatementExportCoordinator(
    this.walletListBloc,
    this.accountMenuModel,
  );

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final walletManager = serviceManager.get<WalletManager>();
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final viewModel = WalletAccountStatementExportViewModelImpl(
      walletListBloc,
      accountMenuModel,
      this,
      walletManager,
      dataProviderManager,
    );
    widget = WalletAccountStatementExportView(
      viewModel,
    );
    return widget;
  }
}

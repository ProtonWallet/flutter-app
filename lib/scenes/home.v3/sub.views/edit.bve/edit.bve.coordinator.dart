import 'dart:ui';

import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/edit.bve/edit.bve.view.dart';
import 'package:wallet/scenes/home.v3/sub.views/edit.bve/edit.bve.viewmodel.dart';

class EditBvECoordinator extends Coordinator {
  late ViewBase widget;
  final WalletListBloc walletListBloc;
  final VoidCallback? callback;
  final WalletModel walletModel;
  final AccountModel accountModel;

  EditBvECoordinator(
    this.walletListBloc,
    this.walletModel,
    this.accountModel,
    this.callback,
  );

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final walletManager = serviceManager.get<WalletManager>();
    final appStateManager = serviceManager.get<AppStateManager>();
    final viewModel = EditBvEViewModelImpl(
      this,
      appStateManager,
      dataProviderManager,
      walletManager,
      walletListBloc,
      walletModel,
      accountModel,
      callback,
    );
    widget = EditBvEView(
      viewModel,
    );
    return widget;
  }
}

import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/features/wallet/create.wallet.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';

import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/import/import.view.dart';
import 'package:wallet/scenes/import/import.viewmodel.dart';

class ImportCoordinator extends Coordinator {
  late ViewBase widget;

  final String preInputName;

  ImportCoordinator(this.preInputName);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final userManager = serviceManager.get<UserManager>();
    final apiService = serviceManager.get<ProtonApiServiceManager>();
    final bloc = CreateWalletBloc(
      userManager,
      dataProviderManager.walletDataProvider,
      dataProviderManager.walletKeysProvider,
      dataProviderManager.walletPassphraseProvider,
    );
    final viewModel = ImportViewModelImpl(
      this,
      dataProviderManager,
      preInputName,
      bloc,
      apiService.getApiService(),
    );
    widget = ImportView(
      viewModel,
    );
    return widget;
  }
}

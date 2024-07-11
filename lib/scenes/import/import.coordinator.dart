import 'package:wallet/managers/features/create.wallet.bloc.dart';
import 'package:wallet/managers/features/wallet.list.bloc.dart';
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
    var dataProviderManager = serviceManager.get<DataProviderManager>();
    var userManager = serviceManager.get<UserManager>();
    var bloc = CreateWalletBloc(
      userManager,
      dataProviderManager.walletDataProvider,
      dataProviderManager.walletKeysProvider,
      dataProviderManager.walletPassphraseProvider,
    );
    var viewModel = ImportViewModelImpl(
      this,
      dataProviderManager,
      preInputName,
      bloc,
    );
    widget = ImportView(
      viewModel,
    );
    return widget;
  }
}

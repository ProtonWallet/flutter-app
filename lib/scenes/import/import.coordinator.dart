import 'package:wallet/constants/proton.color.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/features/wallet/create.wallet.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';

import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/import.success/import.success.coordinator.dart';
import 'package:wallet/scenes/home.v3/sub.views/upgrade/upgrade.coordinator.dart';
import 'package:wallet/scenes/import/import.view.dart';
import 'package:wallet/scenes/import/import.viewmodel.dart';

class ImportCoordinator extends Coordinator {
  late ViewBase widget;

  final String preInputName;

  ImportCoordinator(this.preInputName);

  void showImportSuccess() {
    final view = ImportSuccessCoordinator().start();
    showInBottomSheet(view);
  }

  @override
  void end() {}

  void showUpgrade() {
    showInBottomSheet(
      UpgradeCoordinator(isWalletAccountExceedLimit: false).start(),
      backgroundColor: ProtonColors.white,
    );
  }

  @override
  ViewBase<ViewModel> start() {
    final dataProviderManager = serviceManager.get<DataProviderManager>();
    final userManager = serviceManager.get<UserManager>();
    final walletManager = serviceManager.get<WalletManager>();
    final apiServiceManager = serviceManager.get<ProtonApiServiceManager>();
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
      apiServiceManager.getApiService(),
      walletManager,
      apiServiceManager.getApiService().getProtonEmailAddrClient(),
    );
    widget = ImportView(
      viewModel,
    );
    return widget;
  }
}

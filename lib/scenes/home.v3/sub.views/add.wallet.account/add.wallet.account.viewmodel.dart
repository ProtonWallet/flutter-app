import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet/create.wallet.bloc.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/add.wallet.account/add.wallet.account.coordinator.dart';

abstract class AddWalletAccountViewModel
    extends ViewModel<AddWalletAccountCoordinator> {
  AddWalletAccountViewModel(super.coordinator);

  Future<bool> addWalletAccount(
    ScriptTypeInfo scriptType,
    String label,
    int accountIndex,
  );

  String errorMessage = "";

  late ValueNotifier newAccountScriptTypeValueNotifier;
  late TextEditingController newAccountNameController;
  late TextEditingController newAccountIndexController;

  final FocusNode newAccountNameFocusNode = FocusNode();
  final FocusNode newAccountIndexFocusNode = FocusNode();

  bool isAdding = false;
}

class AddWalletAccountViewModelImpl extends AddWalletAccountViewModel {
  final AppStateManager appStateManager;
  final WalletsDataProvider walletDataProvider;
  final CreateWalletBloc createWalletBloc;
  final FiatCurrency fiatCurrency;
  final String walletID;

  AddWalletAccountViewModelImpl(
    this.appStateManager,
    this.createWalletBloc,
    this.walletDataProvider,
    this.fiatCurrency,
    this.walletID,
    super.coordinator,
  );

  Future<void> initControllers() async {
    final accountIndex = await walletDataProvider.getNewDerivationAccountIndex(
      walletID,
      appConfig.scriptTypeInfo,
      appConfig.coinType,
    );

    newAccountScriptTypeValueNotifier = ValueNotifier(appConfig.scriptTypeInfo);
    newAccountNameController =
        TextEditingController(text: "Account $accountIndex");
    newAccountIndexController =
        TextEditingController(text: accountIndex.toString());

    newAccountScriptTypeValueNotifier.addListener(() async {
      /// get lowest unused account index when user change script type
      final int accountIndex =
          await walletDataProvider.getNewDerivationAccountIndex(
        walletID,
        newAccountScriptTypeValueNotifier.value,
        appConfig.coinType,
      );
      newAccountIndexController.text = accountIndex.toString();
    });
  }

  @override
  Future<void> loadData() async {
    await initControllers();
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  Future<bool> addWalletAccount(
    ScriptTypeInfo scriptType,
    String label,
    int accountIndex,
  ) async {
    try {
      await createWalletBloc.createWalletAccount(
        walletID,
        scriptType,
        label,
        fiatCurrency,
        accountIndex,
      );
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      errorMessage = parseSampleDisplayError(e);
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      if (errorMessage.toLowerCase() ==
          "You have reached the creation limit for this type of wallet account"
              .toLowerCase()) {
        /// reach maximum wallet account limit, needs to show upgrade page
        errorMessage = "";
        final BuildContext? context =
            Coordinator.rootNavigatorKey.currentContext;
        if (context != null && context.mounted) {
          coordinator.showUpgrade(
            isWalletAccountExceedLimit: true,
          );
        }
        return false;
      }
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
      return false;
    }
    return true;
  }
}

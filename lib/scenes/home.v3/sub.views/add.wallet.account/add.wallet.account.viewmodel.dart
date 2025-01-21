import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/extension/response.error.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet/create.wallet.bloc.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
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

  final newAccountScriptTypeValueNotifier = ValueNotifier(
    appConfig.scriptTypeInfo,
  );
  final newAccountNameController = TextEditingController();
  final newAccountIndexController = TextEditingController();

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

    newAccountNameController.text = "Account $accountIndex";
    newAccountIndexController.text = accountIndex.toString();

    newAccountScriptTypeValueNotifier.addListener(() async {
      /// get lowest unused account index when user change script type
      final accountIndex =
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
      final responsError = parseResponseError(e);
      if (responsError != null && responsError.isCreationLimition()) {
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          CommonHelper.showInfoDialog(responsError.error);
          return false;
        } else {
          coordinator.showUpgrade();
        }
        return false;
      }

      final msg = parseSampleDisplayError(e);
      CommonHelper.showErrorDialog(msg);
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
    } catch (e, stacktrace) {
      CommonHelper.showErrorDialog(e.toString());
      Sentry.captureException(e, stackTrace: stacktrace);
      return false;
    }

    return true;
  }
}

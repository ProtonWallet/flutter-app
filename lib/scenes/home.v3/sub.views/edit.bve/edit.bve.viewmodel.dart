import 'dart:async';
import 'dart:ui';

import 'package:wallet/helper/common.helper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/edit.bve/edit.bve.coordinator.dart';

abstract class EditBvEViewModel extends ViewModel<EditBvECoordinator> {
  final DataProviderManager dataProviderManager;
  final WalletManager walletManager;
  final AppStateManager appStateManager;
  final WalletListBloc walletListBloc;
  final VoidCallback? callback;
  final WalletModel walletModel;
  final AccountModel accountModel;
  List<String> usedEmailIDs = [];
  List<ProtonAddress> userAddresses = [];
  String? selectedEmailID;
  bool initialized = false;
  String errorMessage = "";

  void updateSelectedEmailID(emailID);

  Future<bool> addEmailAddressToWalletAccount();

  EditBvEViewModel(
    super.coordinator,
    this.appStateManager,
    this.dataProviderManager,
    this.walletManager,
    this.walletListBloc,
    this.walletModel,
    this.accountModel,
    this.callback,
  );
}

class EditBvEViewModelImpl extends EditBvEViewModel {
  EditBvEViewModelImpl(
    super.coordinator,
    super.appStateManager,
    super.dataProviderManager,
    super.walletManager,
    super.walletListBloc,
    super.walletModel,
    super.accountModel,
    super.callback,
  );

  Future<void> loadProtonAddresses() async {
    try {
      userAddresses =
          await dataProviderManager.addressKeyProvider.getAddresses();
    } catch (e) {
      logger.e(e.toString());
    }
  }

  @override
  Future<void> loadData() async {
    /// get used email ids from wallet list bloc
    usedEmailIDs = walletListBloc.getUsedEmailIDs();

    /// load user addresses
    await loadProtonAddresses();

    initialized = true;
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  void updateSelectedEmailID(emailID) {
    selectedEmailID = emailID;
    sinkAddSafe();
  }

  @override
  Future<bool> addEmailAddressToWalletAccount() async {
    if (selectedEmailID == null) {
      return false;
    }

    try {
      /// update db tables
      await walletManager.addEmailAddress(
        walletModel.walletID,
        accountModel.accountID,
        selectedEmailID!,
      );

      /// update memory caches
      walletListBloc.addEmailIntegration(
        walletModel,
        accountModel,
        selectedEmailID!,
      );
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      errorMessage = parseSampleDisplayError(e);
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog(errorMessage);
      errorMessage = "";
      sinkAddSafe();
      return false;
    }

    sinkAddSafe();
    return true;
  }
}

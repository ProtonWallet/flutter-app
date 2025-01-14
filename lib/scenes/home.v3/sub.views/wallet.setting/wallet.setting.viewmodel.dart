import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/wallet.balance/wallet.balance.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/features/wallet/wallet.name.bloc.dart';
import 'package:wallet/managers/providers/address.keys.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/rust/api/api_service/settings_client.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.setting/wallet.setting.coordinator.dart';

class AccountSettingInfo {
  bool bveEnabled;
  final TextEditingController nameController;
  final ValueNotifier fiatCurrencyNotifier;
  final FocusNode nameFocusNode;

  AccountSettingInfo(
    this.nameController,
    this.fiatCurrencyNotifier,
    this.nameFocusNode, {
    required this.bveEnabled,
  });
}

abstract class WalletSettingViewModel
    extends ViewModel<WalletSettingCoordinator> {
  final WalletListBloc walletListBloc;
  final WalletBalanceBloc walletBalanceBloc;
  final WalletNameBloc walletNameBloc;
  final WalletMenuModel walletMenuModel;

  late ScrollController scrollController;
  late TextEditingController walletNameController;
  late FocusNode walletNameFocusNode;

  List<AccountModel> userAccounts = [];
  List<ProtonAddress> userAddresses = [];
  Map<String, AccountSettingInfo> accountID2SettingInfo = {};

  final bitcoinUnitNotifier = ValueNotifier(BitcoinUnit.btc);

  String errorMessage = "";
  bool isRemovingBvE = false;
  bool initialized = false;

  void updateRemovingBvE(isRemoving);

  void updateBvEEnabledStatus(String accountID, enabled);

  Future<void> updateWalletName(String newName);

  Future<void> updateAccountName(
    AccountModel accountModel,
    String newName,
  );

  Future<void> updateWalletAccountFiatCurrency(
    AccountModel accountModel,
    FiatCurrency newFiatCurrency,
  );

  Future<void> removeEmailAddressFromWalletAccount(
    AccountModel accountModel,
    String serverAddressID,
  );

  AccountSettingInfo getAccSettingsBy({
    required String accountID,
  });

  bool isBveEnabled(accountID) {
    return getAccSettingsBy(accountID: accountID).bveEnabled;
  }

  ProtonAddress? getProtonAddressByID(
    String addressID,
  );

  WalletSettingViewModel(
    super.coordinator,
    this.walletListBloc,
    this.walletBalanceBloc,
    this.walletNameBloc,
    this.walletMenuModel,
  );

  void showBvEPrivacy({required bool isPrimaryAccount}) {
    coordinator.showBvEPrivacy(isPrimaryAccount: isPrimaryAccount);
  }

  void showWalletAccountSetting(AccountMenuModel accountMenuModel) {
    coordinator.showWalletAccountSetting(accountMenuModel);
  }

  void showDeleteWallet({required bool triggerFromSidebar}) {
    coordinator.showDeleteWallet(triggerFromSidebar: triggerFromSidebar);
  }

  void showEditBvE(
    WalletListBloc walletListBloc,
    AccountModel accountModel,
    VoidCallback? callback,
  ) {
    coordinator.showEditBvE(
      walletListBloc,
      accountModel,
      callback,
    );
  }
}

class WalletSettingViewModelImpl extends WalletSettingViewModel {
  final WalletManager walletManager;
  final AppStateManager appStateManager;

  final SettingsClient settingsClient;
  final WalletClient walletClient;
  final UserSettingsDataProvider userSettingsDataProvider;
  final AddressKeyProvider addressKeyProvider;

  WalletSettingViewModelImpl(
    super.coordinator,
    super.walletListBloc,
    super.walletBalanceBloc,
    super.walletNameBloc,
    super.walletMenuModel,
    this.walletManager,
    this.appStateManager,
    this.userSettingsDataProvider,
    this.addressKeyProvider,
    this.settingsClient,
    this.walletClient,
  );

  @override
  Future<void> updateWalletName(String newName) async {
    try {
      await walletNameBloc.updateWalletName(
        walletMenuModel.walletModel,
        newName,
      );
      walletListBloc.updateWalletName(walletMenuModel.walletModel, newName);
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      errorMessage = parseSampleDisplayError(e);
      logger.e("updateWalletName error: $e, stacktrace: $stacktrace");
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("updateWalletName failed: $errorMessage");
      errorMessage = "";
    }
  }

  @override
  Future<void> updateAccountName(
    AccountModel accountModel,
    String newName,
  ) async {
    try {
      /// update the account name with API, and update db tables
      await walletNameBloc.updateAccountLabel(
        walletMenuModel.walletModel,
        accountModel,
        newName,
      );

      /// update the account name in cache
      walletListBloc.updateAccountName(
        walletMenuModel.walletModel,
        accountModel,
        newName,
      );
    } on BridgeError catch (e, stacktrace) {
      appStateManager.updateStateFrom(e);
      errorMessage = parseSampleDisplayError(e);
      logger.e("updateAccountName error: $e, stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
    } catch (e) {
      errorMessage = e.toString();
    }
    if (errorMessage.isNotEmpty) {
      CommonHelper.showErrorDialog("updateAccountName failed: $errorMessage");
      errorMessage = "";
    }
  }

  @override
  Future<void> updateWalletAccountFiatCurrency(
    AccountModel accountModel,
    FiatCurrency newFiatCurrency,
  ) async {
    walletListBloc.updateAccountFiat(
      walletMenuModel.walletModel,
      accountModel,
      newFiatCurrency.name.toUpperCase(),
    );
    walletBalanceBloc.handleTransactionUpdate();
  }

  @override
  Future<void> loadData() async {
    /// init wallet controllers / notifiers / focusNodes
    scrollController = ScrollController();
    walletNameController = TextEditingController(
      text: walletMenuModel.walletName,
    );
    walletNameFocusNode = FocusNode();

    /// init account setting info
    final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;

    for (final accountMenuModel in walletMenuModel.accounts) {
      final bveEnabled = accountMenuModel.emailIds.isNotEmpty;
      final nameController =
          TextEditingController(text: accountMenuModel.label);
      final fiatCurrencyNotifier =
          ValueNotifier(accountMenuModel.accountModel.getFiatCurrency());
      fiatCurrencyNotifier.addListener(() {
        updateWalletAccountFiatCurrency(
            accountMenuModel.accountModel, fiatCurrencyNotifier.value);
      });
      final nameFocusNode = FocusNode();
      nameFocusNode.addListener(() {
        if (nameFocusNode.hasFocus && context != null) {
          scrollController.jumpTo(scrollController.offset +
              MediaQuery.of(context).viewInsets.bottom);
        }
      });

      final accountSettingInfo = AccountSettingInfo(
        nameController,
        fiatCurrencyNotifier,
        nameFocusNode,
        bveEnabled: bveEnabled,
      );

      accountID2SettingInfo[accountMenuModel.accountModel.accountID] =
          accountSettingInfo;
    }

    /// init bitcoinUnitNotifier
    bitcoinUnitNotifier.addListener(() async {
      updateBitcoinUnit(bitcoinUnitNotifier.value);
    });

    /// load other stuffs
    await loadProtonAddresses();
    await loadUserSettings();

    initialized = true;
    sinkAddSafe();
  }

  Future<void> updateBitcoinUnit(BitcoinUnit symbol) async {
    if (appStateManager.isHomeInitialed) {
      final userSettings = await settingsClient.bitcoinUnit(symbol: symbol);
      await userSettingsDataProvider.insertUpdate(
        userSettings,
      );
      userSettingsDataProvider.updateBitcoinUnit(symbol);
      loadUserSettings();
    }
  }

  Future<void> loadUserSettings() async {
    final settings = await userSettingsDataProvider.getSettings();
    if (settings != null) {
      bitcoinUnitNotifier.value = settings.bitcoinUnit.toBitcoinUnit();
    }
    sinkAddSafe();
  }

  Future<void> loadProtonAddresses() async {
    try {
      userAddresses = await addressKeyProvider.getAddresses();
    } catch (e) {
      logger.e(e.toString());
    }
  }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.addWalletAccount:
        coordinator.showAddWalletAccount();
      case NavID.setupBackup:
        coordinator.showSetupBackup();
      default:
        break;
    }
  }

  @override
  AccountSettingInfo getAccSettingsBy({required String accountID}) {
    try {
      return accountID2SettingInfo[accountID]!;
    } catch (e, stacktrace) {
      logger.e("Event Loop error: $e stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
      return AccountSettingInfo(
        TextEditingController(),
        ValueNotifier(FiatCurrency.usd),
        FocusNode(),
        bveEnabled: false,
      );
    }
  }

  @override
  void updateBvEEnabledStatus(String accountID, enabled) {
    final accountSettingInfo = getAccSettingsBy(accountID: accountID);
    accountSettingInfo.bveEnabled = enabled;
    accountID2SettingInfo[accountID] = accountSettingInfo;
    sinkAddSafe();
  }

  @override
  Future<void> removeEmailAddressFromWalletAccount(
    AccountModel accountModel,
    String serverAddressID,
  ) async {
    try {
      /// remove BvE setting from server with API
      final walletAccount = await walletClient.removeEmailAddress(
        walletId: walletMenuModel.walletModel.walletID,
        walletAccountId: accountModel.accountID,
        addressId: serverAddressID,
      );
      bool deleted = true;

      /// check if server deleted BvE address successfully
      for (final emailAddress in walletAccount.addresses) {
        if (emailAddress.id == serverAddressID) {
          deleted = false;
        }
      }
      if (deleted) {
        /// update db tables
        await walletManager.deleteAddress(serverAddressID);

        /// update caches
        walletListBloc.removeEmailIntegration(
          walletMenuModel.walletModel,
          accountModel,
          serverAddressID,
        );
      }
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
    }
    sinkAddSafe();
  }

  @override
  ProtonAddress? getProtonAddressByID(String addressID) {
    for (final protonAddress in userAddresses) {
      if (protonAddress.id == addressID) {
        return protonAddress;
      }
    }
    return defaultProtonAddress;
  }

  @override
  void updateRemovingBvE(isRemoving) {
    isRemovingBvE = isRemoving;
    sinkAddSafe();
  }
}

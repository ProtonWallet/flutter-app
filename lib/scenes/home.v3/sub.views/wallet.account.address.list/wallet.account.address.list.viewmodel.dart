import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/features/wallet.list/wallet.list.bloc.model.dart';
import 'package:wallet/managers/providers/pool.address.data.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/address.dart';
import 'package:wallet/rust/api/bdk_wallet/blockchain.dart';
import 'package:wallet/rust/common/keychain_kind.dart';
import 'package:wallet/rust/common/pagination.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/home.v3/sub.views/wallet.account.address.list/wallet.account.address.list.coordinator.dart';

enum AddressListType {
  receiveAddress,
  changeAddress,
}

abstract class WalletAccountAddressListViewModel
    extends ViewModel<WalletAccountAddressListCoordinator> {
  WalletAccountAddressListViewModel(
    super.coordinator,
  );

  /// exposed functions for UI
  void showTransactionDetail(frbTransactionDetails);

  void showAddressQRcode(address);

  /// exposed functions for UI
  Future<void> updateAddressListType();

  /// exposed functions for UI
  Future<void> showMoreCallback();

  /// exposed variables for UI
  bool loadingAddress = false;
  bool initialized = false;
  AddressListType addressListType = AddressListType.receiveAddress;
  List<FrbAddressDetails> changeAddresses = [];
  List<FrbAddressDetails> receiveAddresses = [];
  List<String> addressesInPool = [];
  FrbAddressDetails? searchedAddress;

  /// late variables, needs to make sure we initialized them
  late ProtonExchangeRate exchangeRate;
  late TextEditingController searchTextEditingController;
}

class WalletAccountAddressListViewModelImpl
    extends WalletAccountAddressListViewModel {
  WalletAccountAddressListViewModelImpl(
    super.coordinator,
    this.walletManager,
    this.userSettingsDataProvider,
    this.poolAddressDataProvider,
    this.accountMenuModel,
    this.blockchainClient,
  );

  /// api
  final FrbBlockchainClient blockchainClient;

  /// wallet manager
  final WalletManager walletManager;

  /// user settings data provider
  final UserSettingsDataProvider userSettingsDataProvider;

  /// pool address provider to get addresses in pool
  final PoolAddressDataProvider poolAddressDataProvider;

  /// account info
  final AccountMenuModel accountMenuModel;

  /// frbAccount
  late FrbAccount frbAccount;

  /// constants
  final int addressCountPerPage = 10;

  /// internal variables
  int receiveAddressCurrentPage = 0;
  int changeAddressCurrentPage = 0;

  @override
  Future<void> loadData() async {
    /// initialize exchange rate
    exchangeRate = userSettingsDataProvider.exchangeRate;

    /// initialize controller
    searchTextEditingController = TextEditingController();
    searchTextEditingController.addListener(onSearchTextChange);

    /// load frbAccount
    frbAccount = (await walletManager.loadWalletWithID(
      accountMenuModel.accountModel.walletID,
      accountMenuModel.accountModel.accountID,
      serverScriptType: accountMenuModel.accountModel.scriptType,
    ))!;

    /// load addresses in pool
    final walletBitcoinAddresses =
        await poolAddressDataProvider.getWalletBitcoinAddresses(
      accountMenuModel.accountModel.walletID,
      accountMenuModel.accountModel.accountID,
      0,
    );
    addressesInPool = walletBitcoinAddresses
        .map((element) => element.bitcoinAddress ?? "")
        .toList();

    /// load address
    await loadAddresses(addressListType);
    initialized = true;
    sinkAddSafe();
  }

  /// callback when search box text change
  Future<void> onSearchTextChange() async {
    final keyWord = searchTextEditingController.text;
    if (keyWord.isEmpty) {
      searchedAddress = null;
      sinkAddSafe();
      return;
    }
    try {
      searchedAddress = await frbAccount.getAddressFromGraph(
        network: appConfig.coinType.network,
        addressStr: keyWord,
        client: blockchainClient,
        sync_: false,
      );
    } catch (e) {
      /// not found or bitcoin address format error
      searchedAddress = null;
    }
    sinkAddSafe();
  }

  /// load one more page for given address list type
  Future<void> loadAddresses(AddressListType addressListType) async {
    /// skip if we already loading address to prevent user click button twice
    if (loadingAddress) {
      return;
    }
    loadingAddress = true;
    sinkAddSafe();
    try {
      /// calculate start position for current page
      final start = addressListType == AddressListType.receiveAddress
          ? receiveAddressCurrentPage * addressCountPerPage
          : changeAddressCurrentPage * addressCountPerPage;
      final end = addressCountPerPage + 1;

      /// fetch addresses from bdk graph
      final newAddresses = await frbAccount.getAddressesFromGraph(
        pagination: Pagination(
          skip: BigInt.from(start),
          take: BigInt.from(end),
        ),
        client: blockchainClient,
        keychain: addressListType == AddressListType.receiveAddress
            ? KeychainKind.external_
            : KeychainKind.internal,
        sync_: false,
      );

      /// update cache addresses
      if (addressListType == AddressListType.receiveAddress) {
        receiveAddresses = receiveAddresses + newAddresses;
        receiveAddressCurrentPage += 1;
      } else if (addressListType == AddressListType.changeAddress) {
        changeAddresses = changeAddresses + newAddresses;
        changeAddressCurrentPage += 1;
      }
    } catch (e) {
      logger.e(e.toString());
    }
    loadingAddress = false;
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  Future<void> showMoreCallback() async {
    loadAddresses(addressListType);
  }

  @override
  void showTransactionDetail(frbTransactionDetails) {
    coordinator.showHistoryDetails(
      accountMenuModel.accountModel.walletID,
      accountMenuModel.accountModel.accountID,
      frbTransactionDetails,
    );
  }

  @override
  void showAddressQRcode(address) {
    coordinator.showAddressQRcode(address);
  }

  @override
  Future<void> updateAddressListType() async {
    if (addressListType == AddressListType.receiveAddress) {
      addressListType = AddressListType.changeAddress;
      if (changeAddressCurrentPage == 0) {
        /// needs to initialize the change addresses
        await loadAddresses(addressListType);
      }
    } else {
      addressListType = AddressListType.receiveAddress;
    }
    sinkAddSafe();
  }
}

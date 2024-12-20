import 'dart:async';
import 'dart:math';

import 'package:sentry/sentry.dart';
import 'package:wallet/helper/extension/data.dart';
import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/rust/api/api_service/bitcoin_address_client.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/common/address_info.dart';

class ReceiveAddressDataProvider extends DataProvider {
  /// api clients
  final BitcoinAddressClient bitcoinAddressClient;
  final WalletClient walletClient;

  /// memory caches
  final Map<String, FrbAddressInfo> id2AddressInfo = {};

  /// external data providers
  final WalletsDataProvider walletDataProvider;

  ReceiveAddressDataProvider(
    this.bitcoinAddressClient,
    this.walletClient,
    this.walletDataProvider,
  );

  /// stream
  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>();

  /// we need to consider last used index on blockchain
  /// so we will not reuse the address when the cached one
  /// is already been used (i.e. someone send btc on this address)
  Future<void> handleLastUsedIndexOnNetwork(
    FrbAccount account,
    AccountModel accountModel,
    int lastUsedIndexOnNetwork,
  ) async {
    if (lastUsedIndexOnNetwork >= 0) {
      account.markReceiveAddressesUsedTo(from: 0, to: lastUsedIndexOnNetwork);
    }
    final FrbAddressInfo oldAddress = await getReceiveAddress(
      account,
      accountModel,
    );
    if (lastUsedIndexOnNetwork >= oldAddress.index) {
      /// need to generate new receive address when the cached one had been used on blockchain
      await generateNewReceiveAddress(
        account,
        accountModel,
      );
    }
  }

  /// we need to consider bitcoin addresses in server pool
  /// to prevent reuse for receive page
  Future<void> handlePoolIndex(
    FrbAccount account,
    AccountModel accountModel,
  ) async {
    final List<String> addressIDs =
        await WalletManager.getAccountAddressIDs(accountModel.accountID);
    if (addressIDs.isEmpty) {
      /// don't need to check pool index since user didn't enable BvE
      return;
    }

    /// needs to check the highest pool index and mark them as used to avoid reuse bitcoin address
    try {
      final BigInt highestPoolIndex =
          await bitcoinAddressClient.getBitcoinAddressLatestIndex(
              walletId: accountModel.walletID,
              walletAccountId: accountModel.accountID);

      /// we need to use highestPoolIndex+1, since markReceiveAddressesUsedTo(start, end)
      /// only mark used for [start, end)
      final int poolIndex = max(0, highestPoolIndex.toInt() + 1);

      await account.markReceiveAddressesUsedTo(from: 0, to: poolIndex);
    } catch (e, stacktrace) {
      Sentry.captureException(e, stackTrace: stacktrace);
      logger.e(e.toString());
    }
  }

  /// we need to consider last usde index of current wallet account
  /// so we can show same receive address cross platform
  Future<void> handleLastUsedIndex(
    FrbAccount account,
    AccountModel accountModel,
  ) async {
    if (accountModel.lastUsedIndex >= 0) {
      /// we need to use lastUsedIndex+1, since markReceiveAddressesUsedTo(start, end)
      /// only mark used for [start, end)
      await account.markReceiveAddressesUsedTo(
          from: 0, to: accountModel.lastUsedIndex + 1);
    }
  }

  Future<void> initReceiveAddressForAccount(
    FrbAccount account,
    AccountModel accountModel,
  ) async {
    /// we need to mark the addresses under lastUsedIndex from walletAccount as used in bdk,
    /// and mark the pool address as used in bdk as well before we generate index
    await handleLastUsedIndex(account, accountModel);
    await handlePoolIndex(account, accountModel);

    if (!id2AddressInfo.containsKey(accountModel.accountID)) {
      id2AddressInfo[accountModel.accountID] =
          await account.getAddress(index: accountModel.lastUsedIndex);
    }
  }

  Future<FrbAddressInfo> getReceiveAddress(
    FrbAccount account,
    AccountModel accountModel,
  ) async {
    /// we use cached index to avoid generate bitcoin address again when reopen receive page
    if (!id2AddressInfo.containsKey(accountModel.accountID)) {
      await initReceiveAddressForAccount(account, accountModel);
    }
    return id2AddressInfo[accountModel.accountID]!;
  }

  Future<FrbAddressInfo> generateNewReceiveAddress(
    FrbAccount account,
    AccountModel accountModel,
  ) async {
    /// needs to handle lastUsedIndex and highestPoolIndex to prevent address reuse
    await handleLastUsedIndex(account, accountModel);
    await handlePoolIndex(account, accountModel);

    /// get next receive address from bdk
    /// it will skip those addresses that we marked as used,
    /// and return the bitcoin address with smallest unused index
    final FrbAddressInfo newAddress = await account.getNextReceiveAddress();
    id2AddressInfo[accountModel.accountID] = newAddress;

    accountModel.lastUsedIndex = newAddress.index;
    await updateLastUsedIndex(accountModel);

    return id2AddressInfo[accountModel.accountID]!;
  }

  Future<void> updateLastUsedIndex(AccountModel accountModel) async {
    /// put lastUsedIndex to backend, so we can get same receive address cross platform
    walletClient.updateWalletAccountLastUsedIndex(
      walletId: accountModel.walletID,
      walletAccountId: accountModel.accountID,
      lastUsedIndex: accountModel.lastUsedIndex,
    );

    /// update local record
    await walletDataProvider.insertOrUpdateAccount(
      accountModel.walletID,
      accountModel.label.toBase64(),
      accountModel.scriptType,
      accountModel.derivationPath,
      accountModel.accountID,
      accountModel.fiatCurrency.toFiatCurrency(),
      accountModel.poolSize,
      accountModel.priority,
      accountModel.lastUsedIndex,
      notify: false,
    );
  }

  @override
  Future<void> clear() async {
    id2AddressInfo.clear();
    dataUpdateController.close();
  }

  @override
  Future<void> reload() async {}
}

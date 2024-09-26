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
  final BitcoinAddressClient bitcoinAddressClient;
  final WalletClient walletClient;
  final Map<String, FrbAddressInfo> id2AddressInfo = {};

  final WalletsDataProvider walletDataProvider;

  ReceiveAddressDataProvider(
    this.bitcoinAddressClient,
    this.walletClient,
    this.walletDataProvider,
  );

  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>();

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
      /// need to generate new recieve address when the cached one had been used on blockchain
      await generateNewReceiveAddress(
        account,
        accountModel,
      );
    }
  }

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
    try {
      final BigInt highestPoolIndex =
          await bitcoinAddressClient.getBitcoinAddressLatestIndex(
              walletId: accountModel.walletID,
              walletAccountId: accountModel.accountID);

      final int poolIndex = max(0, highestPoolIndex.toInt());

      await account.markReceiveAddressesUsedTo(from: 0, to: poolIndex);
    } catch (e, stacktrace) {
      Sentry.captureException(e, stackTrace: stacktrace);
      logger.e(e.toString());
    }
  }

  Future<void> handleLastUsedIndex(
    FrbAccount account,
    AccountModel accountModel,
  ) async {
    if (accountModel.lastUsedIndex >= 0) {
      await account.markReceiveAddressesUsedTo(
          from: 0, to: accountModel.lastUsedIndex);
    }
  }

  Future<void> initReceiveAddressForAccount(
    FrbAccount account,
    AccountModel accountModel,
  ) async {
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
    if (!id2AddressInfo.containsKey(accountModel.accountID)) {
      await initReceiveAddressForAccount(account, accountModel);
    }
    return id2AddressInfo[accountModel.accountID]!;
  }

  Future<FrbAddressInfo> generateNewReceiveAddress(
    FrbAccount account,
    AccountModel accountModel,
  ) async {
    final FrbAddressInfo newAddress = await account.getNextReceiveAddress();
    id2AddressInfo[accountModel.accountID] = newAddress;

    accountModel.lastUsedIndex = newAddress.index;
    await updateLastUsedIndex(accountModel);

    return id2AddressInfo[accountModel.accountID]!;
  }

  Future<void> updateLastUsedIndex(AccountModel accountModel) async {
    /// don't need await this
    walletClient.updateWalletAccountLastUsedIndex(
      walletId: accountModel.walletID,
      walletAccountId: accountModel.accountID,
      lastUsedIndex: accountModel.lastUsedIndex,
    );
    await walletDataProvider.insertOrUpdateAccount(
      accountModel.walletID,
      accountModel.label.base64encode(),
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

import 'dart:async';
import 'dart:math';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/account.dao.impl.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/bitcoin.address.dao.impl.dart';
import 'package:wallet/models/bitcoin.address.model.dart';
import 'package:wallet/models/wallet.dao.impl.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/common/address_info.dart';

class LocalBitcoinAddress2TransactionData {
  List<String> txids;

  LocalBitcoinAddress2TransactionData({
    this.txids = const [],
  });

  void addTXID(String txid) {
    if (!txids.contains(txid)) {
      txids.add(txid);
    }
  }
}

class BitcoinAddressDetail {
  BitcoinAddressModel bitcoinAddressModel;
  String accountID;
  List<String> txIDs;

  BitcoinAddressDetail({
    required this.bitcoinAddressModel,
    required this.accountID,
    required this.txIDs,
  });
}

class LocalBitcoinAddressData {
  final AccountModel accountModel;
  List<BitcoinAddressDetail> bitcoinAddresses = [];

  LocalBitcoinAddressData({
    required this.accountModel,
    required this.bitcoinAddresses,
  });
}

class LocalBitcoinAddressDataProvider extends DataProvider {
  final WalletDao walletDao;
  final AccountDao accountDao;
  final BitcoinAddressDao bitcoinAddressDao;
  final String userID;

  LocalBitcoinAddressDataProvider(
    this.walletDao,
    this.accountDao,
    this.bitcoinAddressDao,
    this.userID,
  );

  List<LocalBitcoinAddressData> bitcoinAddressDataList = [];

  Map<String, LocalBitcoinAddress2TransactionData>
      bitcoinAddress2TransactionDataMap = {};

  Future<List<LocalBitcoinAddressData>> _getFromDB() async {
    final List<LocalBitcoinAddressData> bitcoinAddressDataList = [];
    final wallets = await walletDao.findAllByUserID(userID);
    if (wallets.isNotEmpty) {
      for (WalletModel walletModel in wallets) {
        final accounts =
            await accountDao.findAllByWalletID(walletModel.walletID);
        for (AccountModel accountModel in accounts) {
          final List<BitcoinAddressModel> bitcoinAddresses =
              await bitcoinAddressDao.findByWalletAccount(
                  walletModel.walletID, accountModel.accountID);
          final Map<int, BitcoinAddressModel> addressIndex2bitcoinAddressModel =
              {};
          for (BitcoinAddressModel bitcoinAddressModel in bitcoinAddresses) {
            addressIndex2bitcoinAddressModel[
                bitcoinAddressModel.bitcoinAddressIndex] = bitcoinAddressModel;
          }
          final frbAccountOrNull = (await WalletManager.loadWalletWithID(
            walletModel.walletID,
            accountModel.accountID,
          ));
          if (frbAccountOrNull == null) {
            /// in-case that passphrase wallet is not unlocked
            final LocalBitcoinAddressData localBitcoinAddressData =
                LocalBitcoinAddressData(
              accountModel: accountModel,
              bitcoinAddresses: [],
            );
            bitcoinAddressDataList.add(localBitcoinAddressData);
            continue;
          }
          final FrbAccount frbAccount = frbAccountOrNull;
          final List<BitcoinAddressDetail> finalBitcoinAddresses = [];
          for (int addressIndex = 0;
              addressIndex <= accountModel.lastUsedIndex;
              addressIndex++) {
            if (!addressIndex2bitcoinAddressModel.containsKey(addressIndex)) {
              final addressInfo =
                  await frbAccount.getAddress(index: addressIndex);
              addressIndex2bitcoinAddressModel[addressIndex] =
                  BitcoinAddressModel(
                id: null,
                walletID: 0,
                // deprecated
                accountID: 0,
                // deprecated
                serverWalletID: walletModel.walletID,
                serverAccountID: accountModel.accountID,
                bitcoinAddress: addressInfo.address,
                bitcoinAddressIndex: addressIndex,
                inEmailIntegrationPool: 0,
                used: 0,
              );
            }
            finalBitcoinAddresses.add(BitcoinAddressDetail(
              bitcoinAddressModel:
                  addressIndex2bitcoinAddressModel[addressIndex]!,
              accountID: accountModel.accountID,
              txIDs: [],
            ));
          }

          final LocalBitcoinAddressData localBitcoinAddressData =
              LocalBitcoinAddressData(
            accountModel: accountModel,
            bitcoinAddresses: finalBitcoinAddresses.reversed.toList(),
          );
          bitcoinAddressDataList.add(localBitcoinAddressData);
        }
      }
      return bitcoinAddressDataList;
    }
    return [];
  }

  Future<List<LocalBitcoinAddressData>> getLocalBitcoinAddressDataList() async {
    if (bitcoinAddressDataList.isEmpty) {
      bitcoinAddressDataList = await _getFromDB();
    }
    return bitcoinAddressDataList;
  }

  Future<Map<String, FrbAddressInfo>> getBitcoinAddress(
    WalletModel walletModel,
    AccountModel accountModel,
    FrbAccount? account, {
    int maxAddressIndex = 200,
  }) async {
    if (account == null) {
      return {};
    }
    final Map<String, FrbAddressInfo> bitcoinAddressInfos = {};
    for (int bitcoinAddressIndex = 0;
        bitcoinAddressIndex <= maxAddressIndex;
        bitcoinAddressIndex++) {
      final FrbAddressInfo addressInfo =
          await account.getAddress(index: bitcoinAddressIndex);
      bitcoinAddressInfos[addressInfo.address] = addressInfo;
    }
    return bitcoinAddressInfos;
  }

  /// return -1 if no bitcoin address is used
  /// otherwise return highest used index
  Future<int> getLastUsedIndex(
    WalletModel? walletModel,
    AccountModel? accountModel,
  ) async {
    if (walletModel != null && accountModel != null) {
      // TODO(fix): improve performance
      final LocalBitcoinAddressData localBitcoinAddressData =
          await getDataByWalletAccount(walletModel, accountModel);
      int highestUsedIndex = -1;
      for (BitcoinAddressDetail bitcoinAddressDetail
          in localBitcoinAddressData.bitcoinAddresses) {
        if (bitcoinAddressDetail.bitcoinAddressModel.used == 1) {
          highestUsedIndex = max(highestUsedIndex,
              bitcoinAddressDetail.bitcoinAddressModel.bitcoinAddressIndex);
        }
      }
      return highestUsedIndex;
    }
    return -1;
  }

  Future<LocalBitcoinAddressData> getDataByWalletAccount(
    WalletModel walletModel,
    AccountModel accountModel,
  ) async {
    final List<LocalBitcoinAddressData> localBitcoinAddressDataList =
        await _getFromDB();
    for (LocalBitcoinAddressData localBitcoinAddressData
        in localBitcoinAddressDataList) {
      if (localBitcoinAddressData.accountModel.accountID ==
          accountModel.accountID) {
        return localBitcoinAddressData;
      }
    }
    // no local transaction found for this account, return empty transactions array
    return LocalBitcoinAddressData(
      accountModel: accountModel,
      bitcoinAddresses: [],
    );
  }

  Future<void> insertOrUpdate(BitcoinAddressModel bitcoinAddressModel) async {
    // TODO(fix): enhance performance here
    await bitcoinAddressDao.insertOrUpdate(
      serverWalletID: bitcoinAddressModel.serverWalletID,
      serverAccountID: bitcoinAddressModel.serverAccountID,
      bitcoinAddress: bitcoinAddressModel.bitcoinAddress,
      bitcoinAddressIndex: bitcoinAddressModel.bitcoinAddressIndex,
      inEmailIntegrationPool: bitcoinAddressModel.inEmailIntegrationPool,
      used: bitcoinAddressModel.used,
    );
    bitcoinAddressDataList = await _getFromDB();
  }

  void updateBitcoinAddress2TransactionDataMap(
      String bitcoinAddress, String txid) {
    if (!bitcoinAddress2TransactionDataMap.containsKey(bitcoinAddress)) {
      bitcoinAddress2TransactionDataMap[bitcoinAddress] =
          LocalBitcoinAddress2TransactionData(txids: []);
    }
    bitcoinAddress2TransactionDataMap[bitcoinAddress]!.addTXID(txid);
  }

  Future<BitcoinAddressModel?> findBitcoinAddressInAccount(
      String bitcoinAddress, String serverAccountID) async {
    final BitcoinAddressModel? bitcoinAddressModel = await bitcoinAddressDao
        .findBitcoinAddressInAccount(bitcoinAddress, serverAccountID);
    return bitcoinAddressModel;
  }

  @override
  Future<void> clear() async {}
}

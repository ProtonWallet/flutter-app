import 'dart:async';
import 'package:wallet/managers/providers/data.provider.manager.dart';
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
    if (txids.contains(txid) == false) {
      txids.add(txid);
    }
  }
}

class LocalBitcoinAddressData {
  final AccountModel accountModel;
  List<BitcoinAddressModel> bitcoinAddresses = [];

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
    List<LocalBitcoinAddressData> bitcoinAddressDataList = [];
    var wallets = await walletDao.findAllByUserID(userID);
    if (wallets.isNotEmpty) {
      for (WalletModel walletModel in wallets) {
        var accounts = await accountDao.findAllByWalletID(walletModel.walletID);
        for (AccountModel accountModel in accounts) {
          List<BitcoinAddressModel> bitcoinAddresses =
              await bitcoinAddressDao.findByWalletAccount(
                  walletModel.walletID, accountModel.accountID);
          LocalBitcoinAddressData localBitcoinAddressData =
              LocalBitcoinAddressData(
                  accountModel: accountModel,
                  bitcoinAddresses: bitcoinAddresses);
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
    Map<String, FrbAddressInfo> bitcoinAddressInfos = {};
    for (int bitcoinAddressIndex = 0;
        bitcoinAddressIndex <= maxAddressIndex;
        bitcoinAddressIndex++) {
      FrbAddressInfo addressInfo =
          await account.getAddress(index: bitcoinAddressIndex);
      bitcoinAddressInfos[addressInfo.address] = addressInfo;
    }
    return bitcoinAddressInfos;
  }

  Future<LocalBitcoinAddressData> getDataByWalletAccount(
    WalletModel walletModel,
    AccountModel accountModel,
  ) async {
    List<LocalBitcoinAddressData> localBitcoinAddresDataList =
        await _getFromDB();
    for (LocalBitcoinAddressData localBitcoinAddresData
        in localBitcoinAddresDataList) {
      if (localBitcoinAddresData.accountModel.accountID ==
          accountModel.accountID) {
        return localBitcoinAddresData;
      }
    }
    // no local transaction found for this account, return empty transactions array
    return LocalBitcoinAddressData(
      accountModel: accountModel,
      bitcoinAddresses: [],
    );
  }

  Future<void> insertOrUpdate(BitcoinAddressModel bitcoinAddressModel) async {
    /// TODO:: enhance performance here
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
    if (bitcoinAddress2TransactionDataMap.containsKey(bitcoinAddress) ==
        false) {
      bitcoinAddress2TransactionDataMap[bitcoinAddress] =
          LocalBitcoinAddress2TransactionData(txids: []);
    }
    bitcoinAddress2TransactionDataMap[bitcoinAddress]!.addTXID(txid);
  }

  Future<BitcoinAddressModel?> findBitcoinAddressInAccount(
      String bitcoinAddress, String serverAccountID) async {
    BitcoinAddressModel? bitcoinAddressModel = await bitcoinAddressDao
        .findBitcoinAddressInAccount(bitcoinAddress, serverAccountID);
    return bitcoinAddressModel;
  }

  @override
  Future<void> clear() async {}
}

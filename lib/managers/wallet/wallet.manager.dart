import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/constants/transaction.detail.from.blockchain.dart';
import 'package:wallet/helper/bdk/bdk.library.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/path.helper.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/providers/balance.data.provider.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/bdk_wallet/account.dart';
import 'package:wallet/rust/api/bdk_wallet/address.dart';
import 'package:wallet/rust/api/bdk_wallet/balance.dart';
import 'package:wallet/rust/api/bdk_wallet/storage.dart';
import 'package:wallet/rust/api/bdk_wallet/wallet.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/api/proton_wallet/features/transition_layer.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';

// this is service // per wallet account
class WalletManager implements Manager {
  final BdkLibrary bdkLib = BdkLibrary();

  final UserManager userManager;
  final DataProviderManager dataProviderManager;

  WalletManager(this.userManager, this.dataProviderManager);

  // HashMap<String, FrbWallet> frbWallets = HashMap<String, FrbWallet>();

  Future<FrbAccount?> loadWalletWithID(
    String walletID,
    String accountID, {
    int? serverScriptType,
  }) async {
    final WalletModel? walletModel =
        await DBHelper.walletDao!.findByServerID(walletID);
    if (walletModel == null) return null;
    final walletServerID = walletModel.walletID;

    FrbWallet frbWallet;
    // frbWallets[walletServerID];
    final walletPassProvider = dataProviderManager.walletPassphraseProvider;
    final passphrase = await walletPassProvider.getPassphrase(
      walletServerID,
    );

    final mnemonic = await getMnemonicWithID(walletID);
    if (walletModel.passphrase == 1 && passphrase == null) {
      /// wallet has passphrase, but user didn't set correct passphrase yet
      return null;
    }
    frbWallet = FrbWallet(
      network: appConfig.coinType.network,
      bip39Mnemonic: mnemonic,
      bip38Passphrase: passphrase,
    );
    // frbWallets[walletModel.walletID] = frbWallet;

    final AccountModel? accountModel =
        await DBHelper.accountDao!.findByServerID(accountID);
    if (accountModel == null) {
      logger.e("can not load account");
      return null;
    }
    final derivationPath = accountModel.derivationPath;

    final found = frbWallet.getAccount(derivationPath: derivationPath);
    if (found != null) {
      return found;
    }

    final dbPath = await getDatabaseFolderPath();
    final storage = WalletMobileConnectorFactory(folderPath: dbPath);
    ScriptTypeInfo? scriptTypeInfo;
    for (ScriptTypeInfo info in ScriptTypeInfo.scripts) {
      if (derivationPath.startsWith("m/${info.bipVersion}'/")) {
        scriptTypeInfo = info;
        break;
      }

      /// wallet create from web didn't have m/ prefix
      if (derivationPath.startsWith("${info.bipVersion}'/")) {
        scriptTypeInfo = info;
        break;
      }
    }
    if (scriptTypeInfo != null) {
      if (serverScriptType != null &&
          serverScriptType != scriptTypeInfo.index) {
        logger.e(
          "serverScriptType ($serverScriptType) != scriptTypeInfo.index (${scriptTypeInfo.index})",
        );
      }
      final account = frbWallet.addAccount(
          scriptType: scriptTypeInfo.type,
          derivationPath: derivationPath,
          connectorFactory: storage);

      /// fix the supper big index casued missing transactions during partial sync.
      /// Notes:
      /// * because of bdk bug when caching the FrbAccount, we can't read the transaction from second account.
      /// *  so we dont cache FrbAccount in memory and always load it from cache
      ///
      /// * lastUsedIndex is in memory not in cache so we need to reset it right after load account
      account.markReceiveAddressesUsedTo(
        from: 0,
        to: accountModel.lastUsedIndex,
      );
      return account;
    }
    return null;
  }

  Future<BDKBalanceData> getBDKBalanceDataByWalletAccount(
    WalletModel walletModel,
    AccountModel accountModel,
  ) async {
    final FrbAccount? account = await loadWalletWithID(
      walletModel.walletID,
      accountModel.accountID,
      serverScriptType: accountModel.scriptType,
    );
    return BDKBalanceData(
      walletModel: walletModel,
      accountModel: accountModel,
      account: account,
    );
  }

  ///
  Future<void> cleanBDKCache() async {
    /// dispose the frbWallet so we can delete the local cached sqlite files
    // for (final frbWallet in frbWallets.values) {
    //   frbWallet.dispose();
    // }
    // frbWallets.clear();
    await bdkLib.clearLocalCache();
  }

  Future<void> cleanSharedPreference() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  Future<String> getFingerPrintFromMnemonic(String strMnemonic,
      {String? passphrase}) async {
    final wallet = FrbWallet(
        network: appConfig.coinType.network,
        bip39Mnemonic: strMnemonic,
        bip38Passphrase: passphrase);
    final String fingerprint = wallet.getFingerprint();
    return fingerprint;
  }

  Future<String?> getDerivationPathWithID(String accountID) async {
    final AccountModel? accountModel =
        await DBHelper.accountDao!.findByServerID(accountID);
    if (accountModel == null) {
      return null;
    }
    return accountModel.derivationPath;
  }

  Future<int> getWalletAccountBalance(
    String walletID,
    String walletAccountID,
  ) async {
    try {
      final FrbAccount? frbAccount = await loadWalletWithID(
        walletID,
        walletAccountID,
      );
      if (frbAccount == null) {
        logger.e("getWalletAccountBalance account is null");
        return 0;
      }

      final FrbBalance balance = await frbAccount.getBalance();

      return balance.trustedSpendable().toSat().toInt();
    } catch (e) {
      logger.e(e.toString());
    }
    return 0;
  }

  Future<double> getWalletBalance(String walletID) async {
    double balance = 0.0;
    final accounts = await DBHelper.accountDao!.findAllByWalletID(
      walletID,
    );
    for (AccountModel accountModel in accounts) {
      balance += await getWalletAccountBalance(walletID, accountModel.walletID);
    }
    return balance;
  }

  Future<String> getMnemonicWithID(String walletID) async {
    final walletMnemonicProvider = dataProviderManager.walletMnemonicProvider;
    final mnemonic = await walletMnemonicProvider.getMnemonicWithID(walletID);
    return mnemonic;
  }

  static Future<List<String>> getAccountAddressIDs(
    String serverAccountID,
  ) async {
    final result = await DBHelper.addressDao!.findByServerAccountID(
      serverAccountID,
    );
    return result.map((e) => e.serverID).toList();
  }

  Future<void> deleteAddress(String addressID) async {
    await DBHelper.addressDao!.deleteByServerID(addressID);
  }

  // TODO(Note): this function logic looks strange
  Future<void> autoBindEmailAddresses(String userID) async {
    final int walletCounts = await DBHelper.walletDao!.counts(userID);
    if (walletCounts > 1) {
      return;
    }
    logger.i("Auto binding email address..");
    List<ProtonAddress> protonAddresses = await proton_api.getProtonAddress();
    protonAddresses =
        protonAddresses.where((element) => element.status == 1).toList();
    final ProtonAddress? protonAddress =
        protonAddresses.firstOrNull; // PW-470, can only use primary address
    final WalletModel? walletModel =
        await DBHelper.walletDao!.getFirstPriorityWallet(
      userID,
    );
    if (walletModel != null) {
      final accountModels =
          await DBHelper.accountDao!.findAllByWalletID(walletModel.walletID);
      final AccountModel? accountModel = accountModels.firstOrNull;
      if (accountModel != null && protonAddress != null) {
        await addEmailAddress(
            walletModel.walletID, accountModel.accountID, protonAddress.id);
      }
    }
  }

  Future<void> addEmailAddress(
    String serverWalletID,
    String serverAccountID,
    String serverAddressID,
  ) async {
    final ApiWalletAccount walletAccount = await proton_api.addEmailAddress(
      walletId: serverWalletID,
      walletAccountId: serverAccountID,
      addressId: serverAddressID,
    );

    for (ApiEmailAddress address in walletAccount.addresses) {
      await dataProviderManager.walletDataProvider
          .addEmailAddressToWalletAccount(
        serverWalletID,
        serverAccountID,
        address,
      );
    }
  }

  Future<EmailIntegrationBitcoinAddress?> lookupBitcoinAddress(
    String email,
  ) async {
    final emailIntegrationBitcoinAddress =
        await proton_api.lookupBitcoinAddress(email: email);
    return emailIntegrationBitcoinAddress;
  }

  Future<List<ProtonAddressKey>> getAddressKeysForTL() async {
    final addresses = (await proton_api.getProtonAddress())
        .where((address) => address.status == 1)
        .toList();

    return addresses
        .expand((address) => address.keys ?? [])
        .cast<ProtonAddressKey>()
        .toList();
  }

  Future<List<ProtonAddressKey>> getAddressKeysForTLAddressID(
      List<String> addressIDs) async {
    final addresses = (await proton_api.getProtonAddress())
        .where(
            (address) => address.status == 1 && addressIDs.contains(address.id))
        .toList();

    final addressKeys = addresses
        .expand((address) => address.keys ?? [])
        .cast<ProtonAddressKey>()
        .toList();

    final keys = addressKeys.where((key) => key.primary == 1).toList();
    return keys;
  }

  Future<bool> checkFingerprint(
    WalletModel walletModel,
    String passphrase,
  ) async {
    final strMnemonic = await getMnemonicWithID(walletModel.walletID);
    final fingerprint = await getFingerPrintFromMnemonic(
      strMnemonic,
      passphrase: passphrase,
    );
    logger.i("$fingerprint == ${walletModel.fingerprint}");
    return walletModel.fingerprint == fingerprint;
  }

  Future<void> handleBitcoinAddressRequests(
    FrbAccount account,
    String serverWalletID,
    String serverAccountID,
  ) async {
    final walletBitcoinAddresses = await proton_api.getWalletBitcoinAddress(
        walletId: serverWalletID,
        walletAccountId: serverAccountID,
        onlyRequest: 1);
    final AccountModel? accountModel =
        await DBHelper.accountDao!.findByServerID(serverAccountID);
    if (accountModel != null) {
      await ensureReceivedAddressInitialized(account, accountModel);
    }
    for (final walletBitcoinAddress in walletBitcoinAddresses) {
      if (accountModel == null) {
        logger.e("handleBitcoinAddressRequests: accountModel is null");
        continue;
      }
      if (walletBitcoinAddress.bitcoinAddress == null &&
          walletBitcoinAddress.bitcoinAddressIndex != null) {
        await refillBitcoinAddress(account, walletBitcoinAddress);
      } else if (walletBitcoinAddress.bitcoinAddress == null &&
          walletBitcoinAddress.bitcoinAddressIndex == null) {
        final addressInfo = await account.getNextReceiveAddress();
        final String address = addressInfo.address;
        final String signature = await getSignature(
          serverAccountID,
          address,
          gpgContextWalletBitcoinAddress,
        );
        logger.i(signature);
        final bitcoinAddress = BitcoinAddress(
            bitcoinAddress: address,
            bitcoinAddressSignature: signature,
            bitcoinAddressIndex: BigInt.from(addressInfo.index));
        await proton_api.updateBitcoinAddress(
            walletId: serverWalletID,
            walletAccountId: serverAccountID,
            walletAccountBitcoinAddressId: walletBitcoinAddress.id,
            bitcoinAddress: bitcoinAddress);
        try {
          await DBHelper.bitcoinAddressDao!.insertOrUpdate(
              serverWalletID: serverWalletID,
              serverAccountID: accountModel.accountID,
              bitcoinAddress: address,
              bitcoinAddressIndex: addressInfo.index,
              inEmailIntegrationPool: 1,
              used: 0);
        } catch (e) {
          logger.e(e.toString());
        }
      }
    }
  }

  Future<ApiWalletBitcoinAddress?> refillBitcoinAddress(
    FrbAccount account,
    ApiWalletBitcoinAddress walletBitcoinAddress,
  ) async {
    try {
      if (walletBitcoinAddress.bitcoinAddressIndex == null) {
        return null;
      }
      final addressInfo = await account.getAddress(
          index: walletBitcoinAddress.bitcoinAddressIndex!.toInt());
      final String address = addressInfo.address;
      final String signature = await getSignature(
        walletBitcoinAddress.walletAccountId,
        address,
        gpgContextWalletBitcoinAddress,
      );
      final bitcoinAddress = BitcoinAddress(
          bitcoinAddress: address,
          bitcoinAddressSignature: signature,
          bitcoinAddressIndex: BigInt.from(addressInfo.index));

      final updatedWalletBitcoinAddress = await proton_api.updateBitcoinAddress(
        walletId: walletBitcoinAddress.walletId,
        walletAccountId: walletBitcoinAddress.walletAccountId,
        walletAccountBitcoinAddressId: walletBitcoinAddress.id,
        bitcoinAddress: bitcoinAddress,
      );
      return updatedWalletBitcoinAddress;
    } catch (e) {
      logger.e(e.toString());
    }
    return null;
  }

  Future<void> ensureReceivedAddressInitialized(
    FrbAccount account,
    AccountModel accountModel,
  ) async {
    /// need to initialize receiveAddressDataProvider
    /// so that we can make sure we mark used of the receive address
    /// and the address at [0, lastUsedIndex]
    /// also it will handle the pool index
    await dataProviderManager.receiveAddressDataProvider
        .initReceiveAddressForAccount(account, accountModel);

    /// also need to check localLastUsedIndex (lastUsedIndexOnNetwork)
    final walletModel = await DBHelper.walletDao!.findByServerID(
      accountModel.walletID,
    );
    final localLastUsedIndex = await dataProviderManager
        .localBitcoinAddressDataProvider
        .getLastUsedIndex(walletModel, accountModel);
    await dataProviderManager.receiveAddressDataProvider
        .handleLastUsedIndexOnNetwork(
            account, accountModel, localLastUsedIndex);
  }

  Future<void> bitcoinAddressPoolHealthCheck(
    FrbAccount account,
    String serverWalletID,
    String serverAccountID,
  ) async {
    int unFetchedBitcoinAddressCount = 0;
    // get bitcoin addresses from api, make sure the data is up to date
    final walletBitcoinAddresses = await proton_api.getWalletBitcoinAddress(
        walletId: serverWalletID,
        walletAccountId: serverAccountID,
        onlyRequest: 0);

    /// resync the email address in case that user update it on web
    /// and mobile didn't get event loop yet
    await dataProviderManager.walletDataProvider.syncEmailAddresses(
      serverWalletID,
      serverAccountID,
    );
    final addressIDs = await WalletManager.getAccountAddressIDs(
      serverAccountID,
    );

    if (addressIDs.isEmpty) {
      /// don't need to do health check if no email address link to account
      /// probably due to web disable BvE
      return;
    }
    final addressKeys = await getAddressKeysForTLAddressID(addressIDs);
    for (var walletBitcoinAddress in walletBitcoinAddresses) {
      try {
        final String bitcoinAddress = walletBitcoinAddress.bitcoinAddress ?? "";
        if (bitcoinAddress.isEmpty) {
          /// the address will be wiped by BE when BvE is off
          /// need to refill it when user turn BvE on again
          final ApiWalletBitcoinAddress? updatedWalletBitcoinAddress =
              await refillBitcoinAddress(account, walletBitcoinAddress);
          if (updatedWalletBitcoinAddress != null) {
            walletBitcoinAddress = updatedWalletBitcoinAddress;
          } else {
            continue; //skip since some error occur
          }
        }

        final int addressIndex =
            walletBitcoinAddress.bitcoinAddressIndex?.toInt() ?? -1;
        await account.markReceiveAddressesUsedTo(
          from: addressIndex,
        ); // this will mark address at addressIndex as used
        if (addressIndex >= 0 && bitcoinAddress.isNotEmpty) {
          await DBHelper.bitcoinAddressDao!.insertOrUpdate(
              serverWalletID: serverWalletID,
              serverAccountID: serverAccountID,
              bitcoinAddress: walletBitcoinAddress.bitcoinAddress ?? "",
              bitcoinAddressIndex: addressIndex,
              inEmailIntegrationPool: 1,
              used: walletBitcoinAddress.used);
        }
      } catch (e) {
        logger.e(e.toString());
      }
      if (walletBitcoinAddress.fetched == 0 && walletBitcoinAddress.used == 0) {
        unFetchedBitcoinAddressCount++;
      }
      bool isValidSignature = false;
      if (walletBitcoinAddress.bitcoinAddress != null &&
          walletBitcoinAddress.bitcoinAddressSignature != null) {
        final addressPubKeys =
            addressKeys.map((key) => key.privateKey!).toList();
        isValidSignature = FrbTransitionLayer.verifySignature(
            verifier: addressPubKeys,
            message: walletBitcoinAddress.bitcoinAddress!,
            signature: walletBitcoinAddress.bitcoinAddressSignature!,
            context: gpgContextWalletBitcoinAddress);
      }
      logger.i("bitcoinAddressSignature valid is $isValidSignature");
    }
    final AccountModel? accountModel =
        await DBHelper.accountDao!.findByServerID(serverAccountID);
    int poolSize = defaultBitcoinAddressCountForOneEmail;
    if (accountModel != null) {
      if (accountModel.poolSize > 0) {
        poolSize = accountModel.poolSize;
      }
    }
    final int addingCount = max(0, poolSize - unFetchedBitcoinAddressCount);
    logger.i(
      "walletBitcoinAddresses.length = ${walletBitcoinAddresses.length}, addingCount = $addingCount, unFetchedBitcoinAddressCount=$unFetchedBitcoinAddressCount",
    );
    if (addingCount > 0) {
      final List<BitcoinAddress> apiBitcoinAddresses = [];
      if (accountModel == null) {
        return;
      }
      await ensureReceivedAddressInitialized(account, accountModel);
      for (int offset = 1; offset <= addingCount; offset++) {
        final addressInfo = await account.getNextReceiveAddress();
        final String address = addressInfo.address;
        final String signature = await getSignature(
          serverAccountID,
          address,
          gpgContextWalletBitcoinAddress,
        );
        final BitcoinAddress bitcoinAddress = BitcoinAddress(
            bitcoinAddress: address,
            bitcoinAddressSignature: signature,
            bitcoinAddressIndex: BigInt.from(addressInfo.index));
        apiBitcoinAddresses.add(bitcoinAddress);
      }

      /// BE will rollback and raise an error
      /// if any of bitcoinAddress in apiBitcoinAddresses has issue
      /// So we don't need a recovery process here
      await proton_api.addBitcoinAddresses(
          walletId: serverWalletID,
          walletAccountId: serverAccountID,
          bitcoinAddresses: apiBitcoinAddresses);
      for (BitcoinAddress bitcoinAddress in apiBitcoinAddresses) {
        try {
          await DBHelper.bitcoinAddressDao!.insertOrUpdate(
              serverWalletID: serverWalletID,
              serverAccountID: serverAccountID,
              bitcoinAddress: bitcoinAddress.bitcoinAddress,
              bitcoinAddressIndex: bitcoinAddress.bitcoinAddressIndex.toInt(),
              inEmailIntegrationPool: 1,
              used: 0);
        } catch (e) {
          logger.e(e.toString());
        }
      }
    }
  }

  Future<String> getSignature(
    String serverAccountID,
    String bitcoinAddress,
    String gpgContext,
  ) async {
    final addressIDs = await WalletManager.getAccountAddressIDs(
      serverAccountID,
    );

    final userkeys = await userManager.getUserKeysForTL();
    final passphrase = userManager.getUserKeyPassphrase();
    final addressKeys = await getAddressKeysForTLAddressID(addressIDs);

    final signatures = [];
    for (final addressKey in addressKeys) {
      final signature = FrbTransitionLayer.sign(
        userKeys: userkeys,
        addrKeys: addressKey,
        userKeyPassword: passphrase,
        message: bitcoinAddress,
        context: gpgContext,
      );
      signatures.add(signature);
    }
    return signatures.isNotEmpty
        ? signatures[0]
        : "-----BEGIN PGP SIGNATURE-----*-----END PGP SIGNATURE-----";
  }

  static String getEmailFromWalletTransaction(
    String jsonString, {
    List<String> selfEmailAddresses = const [],
  }) {
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final List<String> emails = [];
      for (var item in jsonList) {
        emails.add(item.values);
      }
      if (emails.length > 1) {
        return "${emails.length} recipients";
      } else {
        return emails.join(", ");
      }
    } catch (e) {
      try {
        final jsonList = jsonDecode(jsonString) as Map<String, dynamic>;
        final List<String> emails = [];
        final List<String> keys = [];
        for (MapEntry<String, dynamic> keyValues in jsonList.entries) {
          // bitcoinAddress as key, emailAddress as value
          keys.add(keyValues.key.toLowerCase());
          if (selfEmailAddresses.contains(keyValues.value)) {
            continue;
          }
          if (keyValues.value.isNotEmpty) {
            emails.add(keyValues.value);
          }
        }
        if (keys.contains("email") && keys.contains("name")) {
          return emails.join(" - ");
        }
        if (emails.length > 1) {
          return "${emails.length} recipients";
        } else {
          return emails.join(", ");
        }
      } catch (e) {
        return jsonString;
      }
    }
  }

  static String getBitcoinAddressFromWalletTransaction(String jsonString,
      {List<String> selfEmailAddresses = const []}) {
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList[0].keys.first;
    } catch (e) {
      try {
        final jsonList = jsonDecode(jsonString) as Map<String, dynamic>;
        for (MapEntry<String, dynamic> keyValues in jsonList.entries) {
          // bitcoinAddress as key, emailAddress as value
          if (selfEmailAddresses.contains(keyValues.value)) {
            continue;
          }
          return keyValues.key;
        }
        return "";
      } catch (e) {
        return jsonString;
      }
    }
  }

  Future<bool> isMineBitcoinAddress(
    FrbAccount account,
    String bitcoinAddress,
  ) async {
    final network = appConfig.coinType.network;
    return account.isMine(
      address: FrbAddress(
        address: bitcoinAddress,
        network: network,
      ),
    );
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> login(String userID) async {}

  @override
  Future<void> reload() async {}

  @override
  Priority getPriority() {
    return Priority.level4;
  }
}

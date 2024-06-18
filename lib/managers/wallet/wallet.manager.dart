import 'dart:collection';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/constants/address.key.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/constants/coin_type.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/constants/transaction.detail.from.blockchain.dart';
import 'package:wallet/helper/bdk/helper.dart';
import 'package:wallet/helper/common_helper.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.passphrase.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/models/exchangerate.model.dart';
import 'package:wallet/rust/api/bdk_wallet.dart';
import 'package:wallet/rust/bdk/types.dart';
import 'package:wallet/constants/script_type.dart';
import 'package:wallet/helper/bdk/mnemonic.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/address.model.dart';
import 'package:wallet/models/transaction.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/proton_api/exchange_rate.dart';
import 'package:wallet/rust/proton_api/proton_address.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';
import 'package:wallet/rust/proton_api/wallet.dart';
import 'package:wallet/rust/proton_api/wallet_account.dart';
import 'package:wallet/scenes/debug/bdk.test.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:http/http.dart' as http;

// this is service // per wallet account
class WalletManager implements Manager {
  static final BdkLibrary _lib = BdkLibrary(coinType: appConfig.coinType);
  static bool isFetchingWallets = false;

  //TODO:: fix me
  static late UserManager userManager;
  static late ProtonWalletManager protonWallet;
  static late WalletKeysProvider walletKeysProvider;
  static late WalletPassphraseProvider walletPassphraseProvider;

  ///
  static HashMap<String, Wallet> wallets = HashMap<String, Wallet>();

  // TODO:: before new_wallet need to check if network changed. if yes need to delete the wallet and create a new one
  // TODO:: return Wallet? to avoid issue, add try-catch here
  static Future<Wallet?> loadWalletWithID(int walletID, int accountID) async {
    WalletModel? walletModel = await DBHelper.walletDao!.findById(walletID);
    if (walletModel == null) return null;
    String passphrase = await walletPassphraseProvider
            .getWalletPassphrase(walletModel.serverWalletID) ??
        "";
    Mnemonic mnemonic = await Mnemonic.fromString(
        await WalletManager.getMnemonicWithID(walletID));
    final DerivationPath derivationPath = await DerivationPath.create(
        path: await getDerivationPathWithID(accountID));
    final aliceDescriptor = await _lib.createDerivedDescriptor(
      mnemonic,
      derivationPath,
      passphrase: passphrase,
    );
    String derivationPathClean =
        derivationPath.toString().replaceAll("'", "_").replaceAll('/', '_');
    String dbName =
        "${walletModel.serverWalletID.replaceAll('-', '_').replaceAll('=', '_')}_${derivationPathClean}_${passphrase.isNotEmpty}";

    var found = wallets[dbName];
    if (found != null) {
      return found;
    }
    var wallet = await _lib.restoreWallet(
      aliceDescriptor,
      databaseName: dbName,
    );
    wallets[dbName] = wallet;
    return wallet;
  }

  ///
  static Future<void> cleanBDKCache() async {
    _lib.clearLocalCache();
  }

  static Future<void> cleanSharedPreference() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  static Future<List<ProtonAddress>> getProtonAddress() async {
    return await proton_api.getProtonAddress();
  }

  static Future<int> getWalletIDByServerWalletID(String serverWalletID) async {
    WalletModel? walletModel =
        await DBHelper.walletDao!.getWalletByServerWalletID(serverWalletID);
    if (walletModel != null) {
      return walletModel.id!;
    }
    return -1;
  }

  static Future<void> addEmailAddressToWalletAccount(
      AccountModel accountModel, ApiEmailAddress address) async {
    WalletModel walletModel =
        await DBHelper.walletDao!.findById(accountModel.walletID);
    AddressModel? addressModel =
        await DBHelper.addressDao!.findByServerID(address.id);
    if (addressModel == null) {
      addressModel = AddressModel(
        id: null,
        email: address.email,
        serverID: address.id,
        serverWalletID: walletModel.serverWalletID,
        serverAccountID: accountModel.serverAccountID,
      );
      await DBHelper.addressDao!.insert(addressModel);
    } else {
      addressModel.email = address.email;
      addressModel.serverID = address.id;
      addressModel.serverWalletID = walletModel.serverWalletID;
      addressModel.serverAccountID = accountModel.serverAccountID;
      await DBHelper.addressDao!.update(addressModel);
    }
  }

  static Future<void> removeEmailAddressInWalletAccount(
      ApiEmailAddress address) async {
    await DBHelper.addressDao!.deleteByServerID(address.id);
  }

  static Future<String> getFingerPrintFromMnemonic(String strMnemonic,
      {String? passphrase}) async {
    BdkWalletManager wallet = await BdkWalletManager.newInstance(
        network: appConfig.coinType.network,
        bip39Mnemonic: strMnemonic,
        bip38Passphrase: passphrase);
    String fingerprint = wallet.fingerprint;
    logger.i("fingerprint = $fingerprint");
    return fingerprint;
  }

  static Future<void> autoCreateWallet() async {
    String walletName = "My Wallet";
    Mnemonic mnemonic = await Mnemonic.create(WordCount.words12);
    await createWallet(walletName, mnemonic.asString(),
        WalletModel.createByProton, defaultFiatCurrency);
  }

  static Future<void> createWallet(String walletName, String mnemonicStr,
      int walletType, FiatCurrency fiatCurrency,
      [String? passphrase]) async {
    SecretKey secretKey = WalletKeyHelper.generateSecretKey();

    var key = await userManager.getFirstKey();

    String userPrivateKey = key.privateKey;
    String userKeyID = key.keyID;

    Uint8List entropy = Uint8List.fromList(await secretKey.extractBytes());
    String encryptedMnemonic =
        await WalletKeyHelper.encrypt(secretKey, mnemonicStr);
    String encryptedWalletName = await WalletKeyHelper.encrypt(
        secretKey, walletName.isNotEmpty ? walletName : "My Wallet");
    String fingerprint = await WalletManager.getFingerPrintFromMnemonic(
        mnemonicStr,
        passphrase:
            passphrase != null && passphrase.isNotEmpty ? passphrase : null);
    String encryptedWalletKey =
        proton_crypto.encryptBinaryArmor(userPrivateKey, entropy);
    String walletKeySignature = proton_crypto.getBinarySignatureWithContext(
        userPrivateKey, key.passphrase, entropy, gpgContextWalletKey);
    CreateWalletReq walletReq = buildWalletRequest(
        encryptedWalletName,
        walletType,
        encryptedMnemonic,
        fingerprint,
        userPrivateKey,
        userKeyID,
        encryptedWalletKey,
        walletKeySignature,
        passphrase != null && passphrase.isNotEmpty);

    ApiWalletData walletData =
        await proton_api.createWallet(walletReq: walletReq);
    int walletID = await processWalletData(
        walletData, walletName, encryptedMnemonic, fingerprint, walletType);
    await WalletManager.setWalletKey([walletData.walletKey]);
    await WalletManager.addWalletAccount(
        walletID, appConfig.scriptType, "My wallet account", fiatCurrency);
  }

  static CreateWalletReq buildWalletRequest(
      String encryptedName,
      int type,
      String mnemonic,
      String fingerprint,
      String userKey,
      String userKeyID,
      String encryptedWalletKey,
      String walletKeySignature,
      bool hasPassphrase) {
    return CreateWalletReq(
      name: encryptedName,
      isImported: type,
      type: WalletModel.typeOnChain,
      hasPassphrase: hasPassphrase ? 1 : 0,
      userKeyId: userKeyID,
      walletKey: encryptedWalletKey,
      //proton_crypto.encryptBinaryArmor(userKey, entropy),
      fingerprint: fingerprint,
      mnemonic: mnemonic,
      walletKeySignature: walletKeySignature,
    );
  }

  static Future<int> processWalletData(ApiWalletData data, String walletName,
      String encMnemonic, String fingerprint, int type) async {
    return await WalletManager.insertOrUpdateWallet(
        userID: 0,
        name: walletName,
        encryptedMnemonic: encMnemonic,
        passphrase: data.wallet.hasPassphrase,
        imported: data.wallet.isImported,
        priority: data.wallet.priority,
        status: data.wallet.status,
        type: data.wallet.type,
        fingerprint: fingerprint,
        serverWalletID: data.wallet.id);
  }

  static Future<void> insertOrUpdateAccount(
      int walletID,
      String labelEncrypted,
      int scriptType,
      String derivationPath,
      String serverAccountID,
      FiatCurrency fiatCurrency) async {
    WalletModel walletModel = await DBHelper.walletDao!.findById(walletID);
    SecretKey? secretKey = await getWalletKey(walletModel.serverWalletID);
    if (walletID != -1) {
      DateTime now = DateTime.now();
      AccountModel? account =
          await DBHelper.accountDao!.findByServerAccountID(serverAccountID);
      if (account != null) {
        account.label = base64Decode(labelEncrypted);
        account.labelDecrypt =
            await WalletKeyHelper.decrypt(secretKey, labelEncrypted);
        account.modifyTime = now.millisecondsSinceEpoch ~/ 1000;
        account.scriptType = scriptType;
        account.fiatCurrency = fiatCurrency.name.toUpperCase();
        await DBHelper.accountDao!.update(account);
      } else {
        account = AccountModel(
            id: null,
            walletID: walletID,
            derivationPath: derivationPath,
            label: base64Decode(labelEncrypted),
            scriptType: scriptType,
            fiatCurrency: fiatCurrency.name.toUpperCase(),
            createTime: now.millisecondsSinceEpoch ~/ 1000,
            modifyTime: now.millisecondsSinceEpoch ~/ 1000,
            serverAccountID: serverAccountID);
        account.labelDecrypt =
            await WalletKeyHelper.decrypt(secretKey, labelEncrypted);
        int accountID = await DBHelper.accountDao!.insert(account);
        account.id = accountID;
      }
    }
  }

  static Future<int> insertOrUpdateWallet(
      {required int userID,
      required String name,
      required String encryptedMnemonic,
      required int passphrase,
      required int imported,
      required int priority,
      required int status,
      required int type,
      required String serverWalletID,
      required String fingerprint}) async {
    WalletModel? wallet =
        await DBHelper.walletDao!.getWalletByServerWalletID(serverWalletID);

    DateTime now = DateTime.now();
    if (wallet == null) {
      wallet = WalletModel(
          id: null,
          userID: userID,
          name: name,
          mnemonic: base64Decode(encryptedMnemonic),
          passphrase: passphrase,
          publicKey: Uint8List(0),
          imported: imported,
          priority: priority,
          status: status,
          type: type,
          fingerprint: fingerprint,
          createTime: now.millisecondsSinceEpoch ~/ 1000,
          modifyTime: now.millisecondsSinceEpoch ~/ 1000,
          serverWalletID: serverWalletID);
      int walletID = await DBHelper.walletDao!.insert(wallet);
      wallet.id = walletID;
    } else {
      wallet.name = name;
      wallet.status = status;
      await DBHelper.walletDao!.update(wallet);
    }
    return wallet.id!;
  }

  static Future<int> getAccountCount(int walletID) async {
    return DBHelper.accountDao!.getAccountCount(walletID);
  }

  static Future<bool> hasWallet() async {
    return await DBHelper.walletDao!.counts() > 0;
  }

  static Future<void> addWalletAccount(int walletID, ScriptType scriptType,
      String label, FiatCurrency fiatCurrency,
      {int internal = 0}) async {
    WalletModel walletModel = await DBHelper.walletDao!.findById(walletID);
    String serverWalletID = walletModel.serverWalletID;
    SecretKey? secretKey = await getWalletKey(serverWalletID);
    String derivationPath = await getNewDerivationPath(
        scriptType, walletID, appConfig.coinType,
        internal: internal);
    CreateWalletAccountReq req = CreateWalletAccountReq(
        label: await WalletKeyHelper.encrypt(secretKey, label),
        derivationPath: derivationPath,
        scriptType: appConfig.scriptType.index);
    ApiWalletAccount walletAccount = await proton_api.createWalletAccount(
      walletId: serverWalletID,
      req: req,
    );

    // TODO:: ask backend to add fiatcurrency parameter when create wallet account
    walletAccount = await proton_api.updateWalletAccountFiatCurrency(
        walletId: serverWalletID,
        walletAccountId: walletAccount.id,
        newFiatCurrency: fiatCurrency);

    await insertOrUpdateAccount(
        walletID,
        walletAccount.label,
        scriptType.index,
        "$derivationPath/$internal",
        walletAccount.id,
        walletAccount.fiatCurrency);
  }

  static Future<String> getNewDerivationPath(
      ScriptType scriptType, int walletID, CoinType coinType,
      {int internal = 0}) async {
    int accountIndex = 0;
    while (true) {
      String newDerivationPath =
          "m/${scriptType.bipVersion}'/${coinType.type}'/$accountIndex'";
      var result = await DBHelper.accountDao!
          .findByDerivationPath(walletID, "$newDerivationPath/$internal");
      if (result == null) {
        return newDerivationPath;
      }
      accountIndex++;
    }
  }

  static Future<String> getDerivationPathWithID(int accountID) async {
    AccountModel accountModel = await DBHelper.accountDao!.findById(accountID);
    logger.w("$accountID: ${accountModel.derivationPath}");
    return accountModel.derivationPath;
  }

  static Future<String> getAccountLabelWithID(int accountID) async {
    AccountModel accountModel = await DBHelper.accountDao!.findById(accountID);
    WalletModel walletModel =
        await DBHelper.walletDao!.findById(accountModel.walletID);
    SecretKey secretKey = await getWalletKey(walletModel.serverWalletID);
    await accountModel.decrypt(secretKey);
    return accountModel.labelDecrypt;
  }

  static Future<String> getNameWithID(int walletID) async {
    String name = "Default Name";
    if (walletID == 0) {
      name = "Default Name";
    } else {
      WalletModel walletRecord = await DBHelper.walletDao!.findById(walletID);
      name = walletRecord.name;
    }
    return name;
  }

  static Future<double> getWalletAccountBalance(
      int walletID, int walletAccountID) async {
    try {
      Wallet? wallet =
          await WalletManager.loadWalletWithID(walletID, walletAccountID);
      // TODO:: handle the !
      Balance balance = await wallet!.getBalance();
      return (balance.trustedPending + balance.confirmed).toDouble();
    } catch (e) {
      logger.e(e.toString());
    }
    return 0.0;
  }

  static Future<double> getWalletBalance(int walletID) async {
    double balance = 0.0;
    List accounts = await DBHelper.accountDao!.findAllByWalletID(walletID);
    for (AccountModel accountModel in accounts) {
      balance += await getWalletAccountBalance(walletID, accountModel.id!);
    }
    return balance;
  }

  static Future<String> getMnemonicWithID(int walletID) async {
    WalletModel walletModel = await DBHelper.walletDao!.findById(walletID);

    var firstKey = await userManager.getFirstKey();
    var walletKey =
        await walletKeysProvider.getWalletKey(walletModel.serverWalletID);
    if (walletKey == null) {
      throw Exception("Wallet key not found");
    }
    var pgpBinaryMessage = walletKey.walletKey;
    // var signature = walletKey.walletKeySignature;
    var entropy = proton_crypto.decryptBinaryPGP(
        firstKey.privateKey, firstKey.passphrase, pgpBinaryMessage);

    var secretKey = WalletKeyHelper.restoreSecretKeyFromEntropy(entropy);
    // SecretKey? secretKey =
    // await protonWallet.getWalletKey(walletModel.serverWalletID);
    String mnemonic = await WalletKeyHelper.decrypt(
        secretKey, base64Encode(walletModel.mnemonic));
    return mnemonic;
  }

  static Future<ProtonExchangeRate> getExchangeRate(FiatCurrency fiatCurrency,
      {int? time}) async {
    ProtonExchangeRate exchangeRate = await proton_api.getExchangeRate(
        fiatCurrency: fiatCurrency, time: time);
    return exchangeRate;
  }

  static int getCurrentTime() {
    return DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
  }

  static Future<List<String>> getAccountAddressIDs(
      String serverAccountID) async {
    List<AddressModel> result =
        await DBHelper.addressDao!.findByServerAccountID(serverAccountID);
    return result.map((e) => e.serverID).toList();
  }

  static Future<void> deleteAddress(String addressID) async {
    await DBHelper.addressDao!.deleteByServerID(addressID);
  }

  static Future<void> autoBindEmailAddresses() async {
    int walletCounts = await DBHelper.walletDao!.counts();
    if (walletCounts > 1) {
      return;
    }
    logger.i("Auto binding email address..");
    List<ProtonAddress> protonAddresses = await proton_api.getProtonAddress();
    protonAddresses =
        protonAddresses.where((element) => element.status == 1).toList();
    ProtonAddress? protonAddress =
        protonAddresses.firstOrNull; // PW-470, can only use primary address
    WalletModel? walletModel =
        await DBHelper.walletDao!.getFirstPriorityWallet();
    if (walletModel != null) {
      List<AccountModel> accountModels =
          (await DBHelper.accountDao!.findAllByWalletID(walletModel.id!))
              .cast<AccountModel>();
      AccountModel? accountModel = accountModels.firstOrNull;
      if (accountModel != null && protonAddress != null) {
        await addEmailAddress(walletModel.serverWalletID,
            accountModel.serverAccountID, protonAddress.id);
      }
    }
  }

  static Future<void> addEmailAddress(String serverWalletID,
      String serverAccountID, String serverAddressID) async {
    ApiWalletAccount walletAccount = await proton_api.addEmailAddress(
        walletId: serverWalletID,
        walletAccountId: serverAccountID,
        addressId: serverAddressID);
    AccountModel accountModel =
        await DBHelper.accountDao!.findByServerAccountID(serverAccountID);
    for (ApiEmailAddress address in walletAccount.addresses) {
      await WalletManager.addEmailAddressToWalletAccount(accountModel, address);
    }
  }

  static Future<Uint8List> decryptBinaryWithUserKeys(
      String encodedEncryptedBinary) async {
    var key = await userManager.getFirstKey();
    String userPrivateKey = key.privateKey;
    String userPassphrase = key.passphrase;

    Uint8List result = Uint8List(0);
    try {
      result = proton_crypto.decryptBinary(
          userPrivateKey, userPassphrase, base64Decode(encodedEncryptedBinary));
    } catch (e) {
      logger.e(e.toString());
    }
    return result;
  }

  static Future<String> decryptWithUserKeys(String encryptedMessage) async {
    var key = await userManager.getFirstKey();
    String userPrivateKey = key.privateKey;
    String userPassphrase = key.passphrase;
    String result = "";
    try {
      result = proton_crypto.decrypt(
          userPrivateKey, userPassphrase, encryptedMessage);
    } catch (e) {
      logger.e(e.toString());
    }
    return result;
  }

  static Future<void> fetchWalletsFromServer() async {
    /// lagecy code, use walletDataProvider to fetch data from server
  }

  static Future<void> setLatestEventId(String latestEventId) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("latestEventId", latestEventId);
  }

  static Future<String?> getLatestEventId() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString("latestEventId");
  }

  static Future<EmailIntegrationBitcoinAddress?> lookupBitcoinAddress(
      String email) async {
    EmailIntegrationBitcoinAddress emailIntegrationBitcoinAddress =
        await proton_api.lookupBitcoinAddress(email: email);
    // TODO:: check signature!
    return emailIntegrationBitcoinAddress;
  }

  static Future<List<AddressKey>> getAddressKeys() async {
    List<ProtonAddress> addresses = await proton_api.getProtonAddress();
    addresses = addresses.where((element) => element.status == 1).toList();

    var key = await userManager.getFirstKey();
    String userPrivateKey = key.privateKey;
    String userPassphrase = key.passphrase;

    List<AddressKey> addressKeys = [];

    for (ProtonAddress address in addresses) {
      for (ProtonAddressKey addressKey in address.keys ?? []) {
        String addressKeyPrivateKey = addressKey.privateKey ?? "";
        String addressKeyToken = addressKey.token ?? "";
        try {
          String addressKeyPassphrase = proton_crypto.decrypt(
              userPrivateKey, userPassphrase, addressKeyToken);
          addressKeys.add(AddressKey(
              id: address.id,
              privateKey: addressKeyPrivateKey,
              passphrase: addressKeyPassphrase));
        } catch (e) {
          logger.e(e.toString());
        }
      }
    }

    // TODO:: remove this, use old version decrypt method to get addresskeys' passphrase
    addressKeys.add(AddressKey(
        id: "firstUserKey",
        privateKey: userPrivateKey,
        passphrase: userPassphrase));
    return addressKeys;
  }

  static Future<void> handleWalletTransaction(WalletModel walletModel,
      List<AddressKey> addressKeys, WalletTransaction walletTransaction) async {
    DateTime now = DateTime.now();
    String txid = "";
    for (AddressKey addressKey in addressKeys) {
      try {
        txid = addressKey.decrypt(walletTransaction.transactionId);
        if (txid.isNotEmpty) {
          break;
        }
      } catch (e) {
        logger.e(e.toString());
      }
    }
    if (txid.isEmpty) {
      var key = await userManager.getFirstKey();
      String userPrivateKey = key.privateKey;
      String userPassphrase = key.passphrase;
      txid = proton_crypto.decrypt(
          userPrivateKey, userPassphrase, walletTransaction.transactionId);
    }
    String exchangeRateID = "";
    if (walletTransaction.exchangeRate != null) {
      exchangeRateID = walletTransaction.exchangeRate!.id;
      ExchangeRateModel exchangeRateModel = ExchangeRateModel(
        id: null,
        serverID: walletTransaction.exchangeRate!.id,
        bitcoinUnit:
            walletTransaction.exchangeRate!.bitcoinUnit.name.toUpperCase(),
        fiatCurrency:
            walletTransaction.exchangeRate!.fiatCurrency.name.toUpperCase(),
        sign: "",
        // TODO:: add sign once apiClient update for it
        exchangeRateTime: walletTransaction.exchangeRate!.exchangeRateTime,
        exchangeRate: walletTransaction.exchangeRate!.exchangeRate,
        cents: walletTransaction.exchangeRate!.cents,
      );
      await DBHelper.exchangeRateDao!.insert(exchangeRateModel);
    }
    TransactionModel transactionModel = TransactionModel(
        id: null,
        walletID: walletModel.id!,
        label: utf8.encode(walletTransaction.label ?? ""),
        externalTransactionID: utf8.encode(txid),
        createTime: now.millisecondsSinceEpoch ~/ 1000,
        modifyTime: now.millisecondsSinceEpoch ~/ 1000,
        hashedTransactionID:
            utf8.encode(walletTransaction.hashedTransactionId ?? ""),
        transactionID: walletTransaction.transactionId,
        serverID: walletTransaction.id,
        transactionTime: walletTransaction.transactionTime,
        exchangeRateID: exchangeRateID,
        serverWalletID: walletTransaction.walletId,
        serverAccountID: walletTransaction.walletAccountId!,
        sender: walletTransaction.sender,
        tolist: walletTransaction.tolist,
        subject: walletTransaction.subject,
        body: walletTransaction.body);
    await DBHelper.transactionDao!.insertOrUpdate(transactionModel);
  }

  static Future<bool> checkFingerprint(
      WalletModel walletModel, String passphrase) async {
    String strMnemonic = await WalletManager.getMnemonicWithID(walletModel.id!);
    String fingerprint =
        await getFingerPrintFromMnemonic(strMnemonic, passphrase: passphrase);
    logger.i("$fingerprint == ${walletModel.fingerprint}");
    return walletModel.fingerprint == fingerprint;
  }

  static Future<void> handleBitcoinAddressRequests(
      Wallet wallet, String serverWalletID, String serverAccountID) async {
    // TODO:: compute signature!
    List<WalletBitcoinAddress> walletBitcoinAddresses =
        await proton_api.getWalletBitcoinAddress(
            walletId: serverWalletID,
            walletAccountId: serverAccountID,
            onlyRequest: 1);
    bool hasSyncedBitcoinAddressIndex = false;
    AccountModel? accountModel =
        await DBHelper.accountDao!.findByServerAccountID(serverAccountID);
    if (accountModel != null) {
      for (WalletBitcoinAddress walletBitcoinAddress
          in walletBitcoinAddresses) {
        if (walletBitcoinAddress.bitcoinAddress == null) {
          if (hasSyncedBitcoinAddressIndex == false) {
            hasSyncedBitcoinAddressIndex = true;
            await syncBitcoinAddressIndex(serverWalletID, serverAccountID);
          }
          int addressIndex =
              await getBitcoinAddressIndex(serverWalletID, serverAccountID);
          var addressInfo =
              await _lib.getAddress(wallet, addressIndex: addressIndex);
          String address = addressInfo.address;
          String signature = await getSignature(
              accountModel, address, gpgContextWalletBitcoinAddress);
          logger.i(signature);
          BitcoinAddress bitcoinAddress = BitcoinAddress(
              bitcoinAddress: address,
              bitcoinAddressSignature: signature,
              bitcoinAddressIndex: addressIndex);
          await proton_api.updateBitcoinAddress(
              walletId: serverWalletID,
              walletAccountId: serverAccountID,
              walletAccountBitcoinAddressId: walletBitcoinAddress.id,
              bitcoinAddress: bitcoinAddress);
          try {
            WalletModel? walletModel = await DBHelper.walletDao!
                .getWalletByServerWalletID(serverWalletID);
            await DBHelper.bitcoinAddressDao!.insertOrUpdate(
                serverWalletID: walletModel!.serverWalletID,
                serverAccountID: accountModel.serverAccountID,
                bitcoinAddress: address,
                bitcoinAddressIndex: addressIndex,
                inEmailIntegrationPool: 1,
                used: 0);
          } catch (e) {
            logger.e(e.toString());
          }
        }
      }
    }
  }

  static Future<void> syncBitcoinAddressIndex(
      String serverWalletID, String serverAccountID) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String key = "$latestAddressIndex.$serverWalletID.$serverAccountID";
    int latestIndex = preferences.getInt(key) ?? 0;
    int latestIndexFromAPI = 0;
    List<String> addressIDs =
        await WalletManager.getAccountAddressIDs(serverAccountID);
    if (addressIDs.isNotEmpty) {
      logger.i(
          "This wallet account enable email integration, checking latest used index");
      try {
        latestIndexFromAPI = await proton_api.getBitcoinAddressLatestIndex(
            walletId: serverWalletID, walletAccountId: serverAccountID);
      } catch (e) {
        logger.e(e.toString());
      }
    }
    logger.i(
        "serverAccountID = $serverAccountID \nlatestIndex = $latestIndex, latestIndexFromAPI = $latestIndexFromAPI");
    int finalIndex = max(latestIndex, latestIndexFromAPI);
    await preferences.setInt(key, finalIndex);
  }

  static Future<int> getBitcoinAddressIndex(
      String serverWalletID, String serverAccountID) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String key = "$latestAddressIndex.$serverWalletID.$serverAccountID";
    int finalIndex = preferences.getInt(key) ?? 0;
    await preferences.setInt(key, finalIndex + 1);
    return finalIndex + 1;
  }

  static Future<void> bitcoinAddressPoolHealthCheck(
      Wallet wallet, String serverWalletID, String serverAccountID) async {
// TODO:: compute signature!
    int unFetchedBitcoinAddressCount = 0;
    List<WalletBitcoinAddress> walletBitcoinAddresses =
        await proton_api.getWalletBitcoinAddress(
            walletId: serverWalletID,
            walletAccountId: serverAccountID,
            onlyRequest: 0);
    WalletModel? walletModel =
        await DBHelper.walletDao!.getWalletByServerWalletID(serverWalletID);
    AccountModel? accountModel =
        await DBHelper.accountDao!.findByServerAccountID(serverAccountID);
    List<String> addressIDs =
        await WalletManager.getAccountAddressIDs(serverAccountID);
    List<AddressKey> addressKeys = await getAddressKeys();
    addressKeys = addressKeys
        .where((addressKey) => addressIDs.contains(addressKey.id))
        .toList();
    for (WalletBitcoinAddress walletBitcoinAddress in walletBitcoinAddresses) {
      try {
        String bitcoinAddress = walletBitcoinAddress.bitcoinAddress ?? "";
        int addressIndex = walletBitcoinAddress.bitcoinAddressIndex ?? -1;
        if (addressIndex >= 0 && bitcoinAddress.isNotEmpty) {
          await DBHelper.bitcoinAddressDao!.insertOrUpdate(
              serverWalletID: walletModel!.serverWalletID,
              serverAccountID: accountModel!.serverAccountID,
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
        for (AddressKey addressKey in addressKeys) {
          String armoredPublicKey =
              proton_crypto.getArmoredPublicKey(addressKey.privateKey);
          isValidSignature = await verifySignature(
              armoredPublicKey,
              walletBitcoinAddress.bitcoinAddress!,
              walletBitcoinAddress.bitcoinAddressSignature!,
              gpgContextWalletBitcoinAddress);
          if (isValidSignature == true) {
            break;
          }
        }
      }
      logger.i("bitcoinAddressSignature valid is $isValidSignature");
    }
    int addingCount = max(0,
        defaultBitcoinAddressCountForOneEmail - unFetchedBitcoinAddressCount);
    if (walletBitcoinAddresses.isEmpty) {
      int _ = await DBHelper.bitcoinAddressDao!.getUnusedPoolCount(
        walletModel?.serverWalletID ?? "",
        accountModel?.serverAccountID ?? "",
      );
      // addingCount = min(addingCount,
      //     defaultBitcoinAddressCountForOneEmail - localUnusedPoolCount);
      logger.i(
          "update with local pool count\nwalletBitcoinAddresses.length = ${walletBitcoinAddresses.length}, addingCount = $addingCount, unFetchedBitcoinAddressCount=$unFetchedBitcoinAddressCount");
    }
    logger.i(
        "walletBitcoinAddresses.length = ${walletBitcoinAddresses.length}, addingCount = $addingCount, unFetchedBitcoinAddressCount=$unFetchedBitcoinAddressCount");
    if (addingCount > 0) {
      await syncBitcoinAddressIndex(serverWalletID, serverAccountID);
    }
    for (int _ = 0; _ < addingCount; _++) {
      int addressIndex =
          await getBitcoinAddressIndex(serverWalletID, serverAccountID);
      logger.i(
          "Adding bitcoin address index ($addressIndex), serverAccountID = $serverAccountID");
      var addressInfo =
          await _lib.getAddress(wallet, addressIndex: addressIndex);
      String address = addressInfo.address;
      String signature = await getSignature(
          accountModel!, address, gpgContextWalletBitcoinAddress);
      BitcoinAddress bitcoinAddress = BitcoinAddress(
          bitcoinAddress: address,
          bitcoinAddressSignature: signature,
          bitcoinAddressIndex: addressInfo.index);
      await proton_api.addBitcoinAddresses(
          walletId: serverWalletID,
          walletAccountId: serverAccountID,
          bitcoinAddresses: [bitcoinAddress]);
      try {
        WalletModel? walletModel =
            await DBHelper.walletDao!.getWalletByServerWalletID(serverWalletID);
        AccountModel? accountModel =
            await DBHelper.accountDao!.findByServerAccountID(serverAccountID);
        await DBHelper.bitcoinAddressDao!.insertOrUpdate(
            serverWalletID: walletModel!.serverWalletID,
            serverAccountID: accountModel!.serverAccountID,
            bitcoinAddress: address,
            bitcoinAddressIndex: addressIndex,
            inEmailIntegrationPool: 1,
            used: 0);
      } catch (e) {
        logger.e(e.toString());
      }
    }
  }

  static Future<String> getSignature(AccountModel accountModel,
      String bitcoinAddress, String gpgContext) async {
    List<String> addressIDs =
        await WalletManager.getAccountAddressIDs(accountModel.serverAccountID);
    List<AddressKey> addressKeys = await getAddressKeys();
    addressKeys = addressKeys
        .where((addressKey) => addressIDs.contains(addressKey.id))
        .toList();

    List<String> signatures = [];
    for (AddressKey addressKey in addressKeys) {
      signatures.add(proton_crypto.getSignatureWithContext(
          addressKey.privateKey,
          addressKey.passphrase,
          bitcoinAddress,
          gpgContext));
    }
    return signatures.isNotEmpty
        ? signatures[0]
        : "-----BEGIN PGP SIGNATURE-----*-----END PGP SIGNATURE-----";
    // return signatures.join("\n"); // TODO:: add back after check with backend
  }

  static Future<bool> verifySignature(String publicAddressKey, String message,
      String signature, String gpgContext) async {
    return proton_crypto.verifySignatureWithContext(
        publicAddressKey, message, signature, gpgContext);
  }

  static String getEmailFromWalletTransaction(String jsonString,
      {List<String> selfEmailAddresses = const []}) {
    try {
      var jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList[0].values.first;
    } catch (e) {
      try {
        var jsonList = jsonDecode(jsonString) as Map<String, dynamic>;
        for (MapEntry<String, dynamic> keyValues in jsonList.entries) {
          // bitcoinAddress as key, emailAddress as value
          if (selfEmailAddresses.contains(keyValues.value)) {
            continue;
          }
          return keyValues.value;
        }
        return "";
      } catch (e) {
        return jsonString;
      }
    }
  }

  static String getBitcoinAddressFromWalletTransaction(String jsonString,
      {List<String> selfEmailAddresses = const []}) {
    try {
      var jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList[0].keys.first;
    } catch (e) {
      try {
        var jsonList = jsonDecode(jsonString) as Map<String, dynamic>;
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

  static Future<TransactionDetailFromBlockChain?>
      getTransactionDetailsFromBlockStream(String txid) async {
    String baseUrl = "${appConfig.esploraBaseUrl}api";
    try {
      final response = await http.get(Uri.parse('$baseUrl/tx/$txid'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        TransactionDetailFromBlockChain transactionDetailFromBlockChain =
            TransactionDetailFromBlockChain(
                txid: txid,
                feeInSATS: data['fee'],
                blockHeight: data['status']['block_height'] ?? 0,
                timestamp: data['status']['block_time'] ?? 0);
        List<dynamic> recipientMapList = data['vout']
            .map((output) => {
                  'address': output['scriptpubkey_address'],
                  'value': output['value']
                })
            .toList();
        for (var recipientMap in recipientMapList) {
          transactionDetailFromBlockChain.addRecipient(Recipient(
              bitcoinAddress: recipientMap["address"],
              amountInSATS: recipientMap["value"]));
        }
        return transactionDetailFromBlockChain;
      }
    } catch (e) {
      logger.e(e.toString());
    }
    return null;
  }

  static Future<bool> isMineBitcoinAddress(Wallet wallet, String bitcoinAddress,
      {int maxIter = 1000}) async {
    // TODO:: use bdk to check bitcoin address is mine
    for (int addressIndex = 0; addressIndex < maxIter; addressIndex++) {
      var addressInfo =
          await _lib.getAddress(wallet, addressIndex: addressIndex);
      if (addressInfo.address == bitcoinAddress) {
        return true;
      }
    }
    return false;
  }

  static Future<FiatCurrency> getDefaultAccountFiatCurrency(
      WalletModel? walletModel) async {
    if (walletModel != null) {
      AccountModel? accountModel = await DBHelper.accountDao
          ?.findDefaultAccountByWalletID(walletModel.id ?? 0);
      if (accountModel != null) {
        return getAccountFiatCurrency(accountModel);
      }
    }
    return defaultFiatCurrency;
  }

  static FiatCurrency getAccountFiatCurrency(AccountModel? accountModel) {
    if (accountModel != null) {
      return CommonHelper.getFiatCurrencyByName(
          accountModel.fiatCurrency.toUpperCase());
    }
    return defaultFiatCurrency;
  }

  /// ################################################################

  /// trying to get wallet key from secrue store and decrypt it use userkey
  /// TODO:: remove the static
  static Future<SecretKey> getWalletKey(String serverWalletID) async {
    var firstKey = await userManager.getFirstKey();
    var walletKey = await walletKeysProvider.getWalletKey(serverWalletID);
    if (walletKey == null) {
      throw Exception("Wallet key not found");
    }
    var pgpBinaryMessage = walletKey.walletKey;
    // var signature = walletKey.walletKeySignature;
    var entropy = proton_crypto.decryptBinaryPGP(
        firstKey.privateKey, firstKey.passphrase, pgpBinaryMessage);

    var secretKey = WalletKeyHelper.restoreSecretKeyFromEntropy(entropy);
    return secretKey;
  }

  /// TODO:: remove the static
  static Future<void> setWalletKey(List<ApiWalletKey> apiWalletKey) async {
    await walletKeysProvider.saveApiWalletKeys(apiWalletKey);
  }

  /// Mark: base functions

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {}

  @override
  Future<void> login(String userID) async {
    // TODO: implement login
    throw UnimplementedError();
  }
}

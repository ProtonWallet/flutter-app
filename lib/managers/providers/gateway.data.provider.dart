import 'package:wallet/helper/extension/enum.extension.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/rust/api/api_service/onramp_gateway_client.dart';
import 'package:wallet/rust/proton_api/payment_gateway.dart';
import 'package:wallet/rust/proton_api/user_settings.dart';

class GatewayDataProvider extends DataProvider {
  // api client
  final OnRampGatewayClient onRampGatewayClient;

  // memory cache
  Map<GatewayProvider, List<ApiCountry>> countries = {};
  Map<GatewayProvider, List<ApiCountryFiatCurrency>> fiatCurrencies = {};
  Map<GatewayProvider, List<PaymentMethod>> paymentMethods = {};

  // find the list of available providers
  List<GatewayProvider> providers = [];

  /// constructor
  GatewayDataProvider(this.onRampGatewayClient);

  Future<List<String>> getCountries(GatewayProvider provider) async {
    // read from cache

    countries = await onRampGatewayClient.getCountries();

    //
    for (var element in countries.keys) {
      providers.add(element);
    }

    //set default country
    Set<String> uniqueCodesSet = {"US", "CA"};
    var providerCountries = countries[provider];
    if (providerCountries != null) {
      for (var country in providerCountries) {
        uniqueCodesSet.add(country.code);
      }
    }
    return uniqueCodesSet.toList();
  }

  ApiCountry getApiCountry(GatewayProvider provider, String localCode) {
    ApiCountry? apiCountry;
    var providerCountries = countries[provider];
    if (providerCountries != null) {
      for (var country in providerCountries) {
        if (country.code == localCode) {
          apiCountry = country;
        }
      }
    }
    return apiCountry ??
        const ApiCountry(
          code: "US",
          fiatCurrency: "USD",
          name: "United States",
        );
  }

  Future<List<String>> getCurrencies(
      GatewayProvider provider, String localCode) async {
    if (countries.isEmpty) {
      countries = await onRampGatewayClient.getCountries();
    }
    if (fiatCurrencies.isEmpty) {
      fiatCurrencies = await onRampGatewayClient.getFiatCurrencies();
    }
    //set default country
    Set<String> uniqueCodesSet = {};
    var providerCountries = countries[provider];
    if (providerCountries != null) {
      for (var country in providerCountries) {
        if (country.code == localCode) {
          uniqueCodesSet.add(country.fiatCurrency);
        }
      }
    }
    if (uniqueCodesSet.isEmpty) {
      uniqueCodesSet.add("USD");
    }
    return uniqueCodesSet.toList();

    // fiatCurrencies = await onRampGatewayClient.getFiatCurrencies();
    // Set<String> uniqueCodesSet = {};
    // // Iterate over the values in the map
    // for (var countryList in fiatCurrencies.values) {
    //   for (var country in countryList) {
    //     uniqueCodesSet.add(country.symbol);
    //   }
    // }
    // return uniqueCodesSet.toList();
  }

  ApiCountryFiatCurrency getApiCountryFiatCurrency(
    GatewayProvider provider,
    String fiatCurrency,
  ) {
    ApiCountryFiatCurrency? apiCountry;

    var countryFiatCurrencies = fiatCurrencies[provider];
    if (countryFiatCurrencies != null) {
      for (var country in countryFiatCurrencies) {
        if (country.symbol == fiatCurrency) {
          apiCountry = country;
        }
      }
    }

    return apiCountry ??
        ApiCountryFiatCurrency(
          name: fiatCurrency,
          symbol: fiatCurrency,
        );
  }

  Future<void> getPaymentMethods(FiatCurrency fiatCurrency) async {
    paymentMethods = await onRampGatewayClient.getPaymentMethods(
      fiatSymbol: fiatCurrency.enumToString(),
    );
  }

  Future<Map<GatewayProvider, List<Quote>>> getQuote(
      String fiatCurrency, String amount, GatewayProvider provider) async {
    var doubleAmount = double.parse(amount);
    var quote = await onRampGatewayClient.getQuotes(
        amount: doubleAmount, fiatCurrency: fiatCurrency, provider: provider);
    return quote;
  }

  Future<void> checkout() async {}

  // Future<List<WalletData>?> _getFromDB() async {
  //   List<WalletData> retWallet = [];
  //   // try to find it fro cache
  //   var wallets = (await walletDao.findAll())
  //       .cast<WalletModel>(); // TODO:: search by UserID
  //   // if found wallet cache.
  //   if (wallets.isNotEmpty) {
  //     for (WalletModel walleModel in wallets) {
  //       retWallet.add(WalletData(
  //           wallet: walleModel,
  //           accounts: (await accountDao.findAllByWalletID(walleModel.id!))
  //               .cast<AccountModel>()));
  //     }
  //     return retWallet;
  //   }
  //   return null;
  // }

  // Future<List<WalletData>?> getWallets() async {
  //   if (walletsData != null) {
  //     return walletsData;
  //   }

  //   walletsData = await _getFromDB();
  //   if (walletsData != null) {
  //     return walletsData;
  //   }

  //   // try to fetch from server:
  //   List<ApiWalletData> apiWallets = await walletClient.getWallets();
  //   for (ApiWalletData apiWalletData in apiWallets.reversed) {
  //     // update and insert wallet
  //     String serverWalletID = apiWalletData.wallet.id;
  //     int walletID = await _insertOrUpdateWallet(
  //         userID: 0, // this need a string userID
  //         name: apiWalletData.wallet.name,
  //         encryptedMnemonic: apiWalletData.wallet.mnemonic!,
  //         passphrase: apiWalletData.wallet.hasPassphrase,
  //         imported: apiWalletData.wallet.isImported,
  //         priority: apiWalletData.wallet.priority,
  //         status: apiWalletData.wallet.status,
  //         type: apiWalletData.wallet.type,
  //         fingerprint: apiWalletData.wallet.fingerprint ?? "",
  //         publickey: apiWalletData.wallet.publicKey,
  //         serverWalletID: serverWalletID);

  //     List<ApiWalletAccount> apiWalletAccts =
  //         await walletClient.getWalletAccounts(
  //             walletId: apiWalletData.wallet.id); // this id is serverWalletID
  //     for (ApiWalletAccount apiWalletAcct in apiWalletAccts) {
  //       String serverAccountID = apiWalletAcct.id;
  //       await _insertOrUpdateAccount(
  //         walletID, //use server wallet id
  //         apiWalletAcct.label,
  //         apiWalletAcct.scriptType,
  //         "${apiWalletAcct.derivationPath}/0",
  //         apiWalletAcct.id,
  //         apiWalletAcct.fiatCurrency,
  //       );
  //       for (ApiEmailAddress address in apiWalletAcct.addresses) {
  //         _addEmailAddressToWalletAccount(
  //             serverWalletID, serverAccountID, address);
  //       }
  //     }
  //   }

  //   walletsData = await _getFromDB();
  //   if (walletsData != null) {
  //     return walletsData;
  //   }
  //   return null;
  // }

  // Future<int> _insertOrUpdateAccount(
  //     int walletID,
  //     String labelEncrypted,
  //     int scriptType,
  //     String derivationPath,
  //     String serverAccountID,
  //     FiatCurrency fiatCurrency) async {
  //   int accountID = -1;
  //   AccountModel? account =
  //       await accountDao.findByServerAccountID(serverAccountID);
  //   DateTime now = DateTime.now();
  //   if (account != null) {
  //     accountID = account.id ?? -1;
  //     account.walletID = walletID;
  //     account.modifyTime = now.millisecondsSinceEpoch ~/ 1000;
  //     account.scriptType = scriptType;
  //     account.fiatCurrency = fiatCurrency.name.toUpperCase();
  //     await accountDao.update(account);
  //   } else {
  //     account = AccountModel(
  //         id: null,
  //         walletID: walletID,
  //         derivationPath: derivationPath,
  //         label: labelEncrypted.base64decode(),
  //         scriptType: scriptType,
  //         fiatCurrency: fiatCurrency.name.toUpperCase(),
  //         createTime: now.millisecondsSinceEpoch ~/ 1000,
  //         modifyTime: now.millisecondsSinceEpoch ~/ 1000,
  //         serverAccountID: serverAccountID);
  //     accountID = await accountDao.insert(account);
  //   }
  //   return accountID;
  // }

  // Future<int> _insertOrUpdateWallet(
  //     {required int userID,
  //     required String name,
  //     required String encryptedMnemonic,
  //     required int passphrase,
  //     required int imported,
  //     required int priority,
  //     required int status,
  //     required int type,
  //     required String serverWalletID,
  //     required String? publickey,
  //     required String fingerprint}) async {
  //   int walletID = -1;
  //   WalletModel? wallet =
  //       await walletDao.getWalletByServerWalletID(serverWalletID);
  //   DateTime now = DateTime.now();
  //   if (wallet == null) {
  //     Uint8List uPubKey = publickey?.base64decode() ?? Uint8List(0);
  //     wallet = WalletModel(
  //         id: null,
  //         userID: userID,
  //         name: name,
  //         mnemonic: encryptedMnemonic.base64decode(),
  //         passphrase: passphrase,
  //         publicKey: uPubKey,
  //         imported: imported,
  //         priority: priority,
  //         status: status,
  //         type: type,
  //         fingerprint: fingerprint,
  //         createTime: now.millisecondsSinceEpoch ~/ 1000,
  //         modifyTime: now.millisecondsSinceEpoch ~/ 1000,
  //         serverWalletID: serverWalletID);
  //     walletID = await walletDao.insert(wallet);
  //     wallet.id = walletID;
  //   } else {
  //     walletID = wallet.id!;
  //     wallet.name = name;
  //     wallet.status = status;
  //     await walletDao.update(wallet);
  //   }
  //   return walletID;
  // }

  // Future<void> _addEmailAddressToWalletAccount(String serverWalletID,
  //     String serverAccountID, ApiEmailAddress address) async {
  //   AddressModel? addressModel = await addressDao.findByServerID(address.id);
  //   if (addressModel == null) {
  //     addressModel = AddressModel(
  //       id: null,
  //       email: address.email,
  //       serverID: address.id,
  //       serverWalletID: serverWalletID,
  //       serverAccountID: serverAccountID,
  //     );
  //     await addressDao.insert(addressModel);
  //   } else {
  //     addressModel.email = address.email;
  //     addressModel.serverID = address.id;
  //     addressModel.serverWalletID = serverWalletID;
  //     addressModel.serverAccountID = serverAccountID;
  //     await addressDao.update(addressModel);
  //   }
  // }

  @override
  Future<void> clear() async {}
}

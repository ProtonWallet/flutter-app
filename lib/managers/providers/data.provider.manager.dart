import 'dart:async';

import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/providers/address.keys.provider.dart';
import 'package:wallet/managers/providers/balance.data.provider.dart';
import 'package:wallet/managers/providers/bdk.transaction.data.provider.dart';
import 'package:wallet/managers/providers/contacts.data.provider.dart';
import 'package:wallet/managers/providers/local.bitcoin.address.provider.dart';
import 'package:wallet/managers/providers/local.transaction.data.provider.dart';
import 'package:wallet/managers/providers/server.transaction.data.provider.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.passphrase.provider.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/drift/wallet.user.settings.queries.dart';
import 'package:wallet/rust/api/api_service/proton_api_service.dart';

import 'package:wallet/models/drift/db/app.database.dart';

abstract class DataState {}

class DataInitial extends DataState {}

class DataLoading extends DataState {}

class DataLoaded extends DataState {
  final String data;

  DataLoaded(this.data);
}

class DataUpdated extends DataState {
  /// TODO:: maybe specify data update?
  final String updatedData;

  DataUpdated(this.updatedData);
}

class BDKDataUpdated extends DataState {
  BDKDataUpdated();
}

class DataError extends DataState {
  final String message;

  DataError(this.message);
}

abstract class DataProvider {
  Future<void> clear();
}

class DataProviderManager extends Manager {
  final SecureStorageManager storage;
  final ProtonApiService apiService;
  final AppDatabase dbConnection;

  late UserDataProvider userDataProvider;
  late WalletsDataProvider walletDataProvider;
  late WalletPassphraseProvider walletPassphraseProvider;
  late WalletKeysProvider walletKeysProvider;
  late ContactsDataProvider contactsDataProvider;
  late UserSettingsDataProvider userSettingsDataProvider;
  late AddressKeyProvider addressKeyProvider;
  late ServerTransactionDataProvider serverTransactionDataProvider;
  late BDKTransactionDataProvider bdkTransactionDataProvider;
  late LocalTransactionDataProvider localTransactionDataProvider;
  late LocalBitcoinAddressDataProvider localBitcoinAddressDataProvider;
  late BalanceDataProvider balanceDataProvider;

  DataProviderManager(this.storage, this.apiService, this.dbConnection);

  @override
  Future<void> login(String userID) async {
    userDataProvider = UserDataProvider(appDatabase: dbConnection);
    walletPassphraseProvider = WalletPassphraseProvider(storage);
    walletDataProvider = WalletsDataProvider(
      DBHelper.walletDao!,
      DBHelper.accountDao!,
      DBHelper.addressDao!,
      apiService.getWalletClient(),
      "",

      /// TODO:: put selected wallet server id here
      "",

      /// TODO:: put selected wallet account server id here
    );
    walletKeysProvider = WalletKeysProvider(
      storage,
      apiService.getWalletClient(),
    );
    contactsDataProvider = ContactsDataProvider(
      apiService.getProtonContactsClient(),
      DBHelper.contactsDao!,
    );
    userSettingsDataProvider = UserSettingsDataProvider(
      userID,
      WalletUserSettingsQueries(dbConnection),
      apiService.getSettingsClient(),
    );

    addressKeyProvider =
        AddressKeyProvider(apiService.getProtonEmailAddrClient());

    serverTransactionDataProvider = ServerTransactionDataProvider(
      apiService.getWalletClient(),
      DBHelper.walletDao!,
      DBHelper.accountDao!,
      DBHelper.exchangeRateDao!,
      DBHelper.transactionDao!,
    );

    bdkTransactionDataProvider =
        BDKTransactionDataProvider(DBHelper.accountDao!);
    localTransactionDataProvider = LocalTransactionDataProvider(
      apiService.getWalletClient(),
      DBHelper.walletDao!,
      DBHelper.accountDao!,
      DBHelper.transactionInfoDao!,
    );

    localBitcoinAddressDataProvider = LocalBitcoinAddressDataProvider(
      DBHelper.walletDao!,
      DBHelper.accountDao!,
      DBHelper.bitcoinAddressDao!,
    );

    balanceDataProvider = BalanceDataProvider(
      DBHelper.accountDao!,
    );

    // TODO:: fix this
    WalletManager.walletKeysProvider = walletKeysProvider;
    WalletManager.walletPassphraseProvider = walletPassphraseProvider;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {
    await userSettingsDataProvider.clear();
    await userDataProvider.clear();
    await walletDataProvider.clear();
    await walletPassphraseProvider.clear();
    await walletKeysProvider.clear();
    await contactsDataProvider.clear();
  }
}

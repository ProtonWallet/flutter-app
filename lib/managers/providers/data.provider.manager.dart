import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/dbhelper.dart';

import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/providers/address.keys.provider.dart';
import 'package:wallet/managers/providers/bdk.transaction.data.provider.dart';
import 'package:wallet/managers/providers/blockinfo.data.provider.dart';
import 'package:wallet/managers/providers/connectivity.provider.dart';
import 'package:wallet/managers/providers/contacts.data.provider.dart';
import 'package:wallet/managers/providers/exclusive.invite.data.provider.dart';
import 'package:wallet/managers/providers/gateway.data.provider.dart';
import 'package:wallet/managers/providers/local.bitcoin.address.provider.dart';
import 'package:wallet/managers/providers/pool.address.data.provider.dart';
import 'package:wallet/managers/providers/price.graph.data.provider.dart';
import 'package:wallet/managers/providers/proton.address.provider.dart';
import 'package:wallet/managers/providers/receive.address.data.provider.dart';
import 'package:wallet/managers/providers/server.transaction.data.provider.dart';
import 'package:wallet/managers/providers/unleash.data.provider.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.mnemonic.provider.dart';
import 'package:wallet/managers/providers/wallet.name.provider.dart';
import 'package:wallet/managers/providers/wallet.passphrase.provider.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/models/drift/user.keys.queries.dart';
import 'package:wallet/models/drift/users.queries.dart';
import 'package:wallet/models/drift/wallet.user.settings.queries.dart';
import 'package:wallet/models/wallet.keys.store.dart';

/// data state
abstract class DataState extends Equatable {}

class DataInitial extends DataState {
  @override
  List<Object?> get props => [];
}

abstract class DataLoading extends DataState {}

abstract class DataLoaded extends DataState {
  final String data;

  DataLoaded(this.data);
}

abstract class DataCreated extends DataState {}

enum UpdateType {
  inserted,
  updated,
  deleted,
}

class DataUpdated<T> extends DataState {
  final T updatedData;

  DataUpdated(this.updatedData);

  @override
  List<Object?> get props => [updatedData];
}

class SelectedWalletUpdated extends DataState {
  @override
  List<Object?> get props => [];
}

class NewBroadcastTransaction extends DataState {
  @override
  List<Object?> get props => [];
}

abstract class DataDeleted extends DataState {}

class DataError extends DataState {
  final String message;

  DataError(this.message);

  @override
  List<Object?> get props => [message];
}

///
abstract class DataEvent extends Equatable {}

abstract class DataLoad extends DataEvent {}

abstract class DataCreate extends DataEvent {}

abstract class DataUpdate extends DataEvent {}

abstract class DataDelete extends DataEvent {}

class DirectEmitEvent extends DataEvent {
  final DataState state;

  DirectEmitEvent(this.state);

  @override
  List<Object?> get props => [state];
}

abstract class DataProvider extends Bloc<DataEvent, DataState> {
  DataProvider() : super(DataInitial()) {
    on<DirectEmitEvent>((event, emit) => emit(event.state));
  }

  void emitState(DataState state) {
    add(DirectEmitEvent(state));
  }

  Future<void> clear();

  /// reload data
  Future<void> reload();
}

class DataProviderManager extends Manager {
  final SecureStorageManager storage;
  final PreferencesManager shared;
  final ProtonApiServiceManager apiServiceManager;
  final AppDatabase dbConnection;
  final UserManager userManager;
  final ApiEnv apiEnv;

  late UserDataProvider userDataProvider;
  late WalletsDataProvider walletDataProvider;
  late WalletPassphraseProvider walletPassphraseProvider;
  late WalletKeysProvider walletKeysProvider;
  late ContactsDataProvider contactsDataProvider;
  late UserSettingsDataProvider userSettingsDataProvider;
  late AddressKeyProvider addressKeyProvider;
  late ServerTransactionDataProvider serverTransactionDataProvider;
  late BDKTransactionDataProvider bdkTransactionDataProvider;
  late LocalBitcoinAddressDataProvider localBitcoinAddressDataProvider;
  late GatewayDataProvider gatewayDataProvider;
  late ProtonAddressProvider protonAddressProvider;
  late BlockInfoDataProvider blockInfoDataProvider;

  late UnleashDataProvider unleashDataProvider;
  late ExclusiveInviteDataProvider exclusiveInviteDataProvider;
  late ConnectivityProvider connectivityProvider;
  late PriceGraphDataProvider priceGraphDataProvider;
  late ReceiveAddressDataProvider receiveAddressDataProvider;
  late PoolAddressDataProvider poolAddressDataProvider;

  ///
  late WalletMnemonicProvider walletMnemonicProvider;
  late WalletNameProvider walletNameProvider;

  // TODO(improve): this is not good
  late WalletManager walletManager;

  DataProviderManager(
    this.apiEnv,
    this.storage,
    this.shared,
    this.apiServiceManager,
    this.dbConnection,
    this.userManager,
  );

  @override
  Future<void> login(String userID) async {
    /// user data
    userDataProvider = UserDataProvider(
      apiServiceManager.getApiService().getProtonUserClient(),
      UserQueries(dbConnection),
      UserKeysQueries(dbConnection),
    );

    /// wallet passphrase
    walletPassphraseProvider = WalletPassphraseProvider(storage);

    /// wallets and accounts
    walletDataProvider = WalletsDataProvider(
      storage,
      DBHelper.walletDao!,
      DBHelper.accountDao!,
      DBHelper.addressDao!,
      apiServiceManager.getApiService().getWalletClient(),
      "",
      "",
      userID,
    );

    /// wallet keys
    walletKeysProvider = WalletKeysProvider(
      userManager,
      WalletKeyStore(storage),
      apiServiceManager.getApiService().getWalletClient(),
    );

    /// contacts
    contactsDataProvider = ContactsDataProvider(
      apiServiceManager.getApiService().getProtonContactsClient(),
      DBHelper.contactsDao!,
      userID,
    );

    /// user settings
    userSettingsDataProvider = UserSettingsDataProvider(
      userID,
      WalletUserSettingsQueries(dbConnection),
      apiServiceManager.getApiService().getSettingsClient(),
      shared,
    );

    /// on ramp gateway
    gatewayDataProvider = GatewayDataProvider(
      apiServiceManager.getApiService().getOnRampGatewayClient(),
    );

    /// address key
    addressKeyProvider = AddressKeyProvider(
      userManager,
      apiServiceManager.getApiService().getProtonEmailAddrClient(),
      storage,
    );

    /// server transactions
    serverTransactionDataProvider = ServerTransactionDataProvider(
        apiServiceManager.getApiService().getWalletClient(),
        DBHelper.walletDao!,
        DBHelper.accountDao!,
        DBHelper.exchangeRateDao!,
        DBHelper.transactionDao!,
        userManager.userID);

    /// local bitcoin address
    localBitcoinAddressDataProvider = LocalBitcoinAddressDataProvider(
      DBHelper.walletDao!,
      DBHelper.accountDao!,
      DBHelper.bitcoinAddressDao!,
      userID,
      walletManager,
    );

    /// proton address
    protonAddressProvider = ProtonAddressProvider(
      DBHelper.addressDao!,
    );

    /// block info
    blockInfoDataProvider = BlockInfoDataProvider(
      apiServiceManager.getApiService().getBlockClient(),
    );

    /// exclusive invite
    exclusiveInviteDataProvider = ExclusiveInviteDataProvider(
      apiServiceManager.getApiService().getInviteClient(),
    );

    /// connectivity
    connectivityProvider = ConnectivityProvider();

    /// price graph
    priceGraphDataProvider = PriceGraphDataProvider(
      apiServiceManager.getApiService().getPriceGraphClient(),
    );

    /// receive address
    receiveAddressDataProvider = ReceiveAddressDataProvider(
      apiServiceManager.getApiService().getBitcoinAddrClient(),
      apiServiceManager.getApiService().getWalletClient(),
      apiServiceManager.getApiService().getBlockchainClient(),
      walletDataProvider,
    );

    /// pool address
    poolAddressDataProvider = PoolAddressDataProvider(
      apiServiceManager.getApiService().getBitcoinAddrClient(),
    );

    /// wallet mnemonic
    walletMnemonicProvider = WalletMnemonicProvider(
      walletKeysProvider,
      walletDataProvider,
      userManager,
    );

    /// wallet name
    walletNameProvider = WalletNameProvider(
      walletKeysProvider,
      DBHelper.accountDao!,
      DBHelper.walletDao!,
    );

    /// unleash
    unleashDataProvider = UnleashDataProvider(
      apiEnv,
      apiServiceManager.getUnleashClient(),
    );

    /// bdk transactions
    bdkTransactionDataProvider = BDKTransactionDataProvider(
      DBHelper.accountDao!,
      apiServiceManager.getApiService().getWalletClient(),
      apiServiceManager.getApiService().getBlockchainClient(),
      shared,
      walletManager,
      userSettingsDataProvider,
      unleashDataProvider,
    );
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {
    await userDataProvider.clear();
    await walletDataProvider.clear();
    await walletPassphraseProvider.clear();
    await walletKeysProvider.clear();
    await contactsDataProvider.clear();
    await userSettingsDataProvider.clear();
    await addressKeyProvider.clear();
    await serverTransactionDataProvider.clear();
    await bdkTransactionDataProvider.clear();
    await localBitcoinAddressDataProvider.clear();
    await gatewayDataProvider.clear();
    await protonAddressProvider.clear();
    await blockInfoDataProvider.clear();
    await unleashDataProvider.clear();
    await exclusiveInviteDataProvider.clear();
    await connectivityProvider.clear();
    await priceGraphDataProvider.clear();
    await receiveAddressDataProvider.clear();
    await poolAddressDataProvider.clear();
    await walletMnemonicProvider.clear();
    await walletNameProvider.clear();
  }

  @override
  Future<void> reload() async {
    await userDataProvider.reload();
    await walletDataProvider.reload();
    await walletPassphraseProvider.reload();
    await walletKeysProvider.reload();
    await contactsDataProvider.reload();
    await userSettingsDataProvider.reload();
    await addressKeyProvider.reload();
    await serverTransactionDataProvider.reload();
    await bdkTransactionDataProvider.reload();
    await localBitcoinAddressDataProvider.reload();
    await gatewayDataProvider.reload();
    await protonAddressProvider.reload();
    await blockInfoDataProvider.reload();
    await unleashDataProvider.reload();
    await exclusiveInviteDataProvider.reload();
    await connectivityProvider.reload();
    await priceGraphDataProvider.reload();
    await receiveAddressDataProvider.reload();
    await poolAddressDataProvider.reload();
    await walletMnemonicProvider.reload();
    await walletNameProvider.reload();
  }

  @override
  Priority getPriority() {
    return Priority.level4;
  }
}

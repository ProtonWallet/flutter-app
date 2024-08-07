import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/user.agent.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/providers/address.keys.provider.dart';
import 'package:wallet/managers/providers/balance.data.provider.dart';
import 'package:wallet/managers/providers/bdk.transaction.data.provider.dart';
import 'package:wallet/managers/providers/blockinfo.data.provider.dart';
import 'package:wallet/managers/providers/connectivity.provider.dart';
import 'package:wallet/managers/providers/contacts.data.provider.dart';
import 'package:wallet/managers/providers/exclusive.invite.data.provider.dart';
import 'package:wallet/managers/providers/gateway.data.provider.dart';
import 'package:wallet/managers/providers/local.bitcoin.address.provider.dart';
import 'package:wallet/managers/providers/proton.address.provider.dart';
import 'package:wallet/managers/providers/proton.email.address.provider.dart';
import 'package:wallet/managers/providers/server.transaction.data.provider.dart';
import 'package:wallet/managers/providers/unleash.data.provider.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.passphrase.provider.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/models/drift/user.keys.queries.dart';
import 'package:wallet/models/drift/users.queries.dart';
import 'package:wallet/models/drift/wallet.user.settings.queries.dart';
import 'package:wallet/rust/api/api_service/proton_api_service.dart';

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
}

// abstract class DataProvider {
//   Future<void> clear();
// }

class DataProviderManager extends Manager {
  final SecureStorageManager storage;
  final PreferencesManager shared;
  final ProtonApiService apiService;
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
  late BalanceDataProvider balanceDataProvider;
  late GatewayDataProvider gatewayDataProvider;
  late ProtonAddressProvider protonAddressProvider;
  late BlockInfoDataProvider blockInfoDataProvider;
  late UnleashDataProvider unleashDataProvider;
  late ExclusiveInviteDataProvider exclusiveInviteDataProvider;
  late ProtonEmailAddressProvider protonEmailAddressProvider;
  late ConnectivityProvider connectivityProvider;

  DataProviderManager(
    this.apiEnv,
    this.storage,
    this.shared,
    this.apiService,
    this.dbConnection,
    this.userManager,
  );

  @override
  Future<void> login(String userID) async {
    //
    userDataProvider = UserDataProvider(
      apiService.getProtonUserClient(),
      UserQueries(dbConnection),
      UserKeysQueries(dbConnection),
    );
    //
    walletPassphraseProvider = WalletPassphraseProvider(storage);
    // wallets and accounts
    walletDataProvider = WalletsDataProvider(
      DBHelper.walletDao!,
      DBHelper.accountDao!,
      DBHelper.addressDao!,
      apiService.getWalletClient(),
      // TODO(fix): put selected wallet server id here
      "",
      // TODO(fix): put selected wallet account server id here
      "",
      userID,
    );
    //
    walletKeysProvider = WalletKeysProvider(
      storage,
      apiService.getWalletClient(),
    );
    //
    contactsDataProvider = ContactsDataProvider(
      apiService.getProtonContactsClient(),
      DBHelper.contactsDao!,
      userID,
    );
    //
    userSettingsDataProvider = UserSettingsDataProvider(
      userID,
      WalletUserSettingsQueries(dbConnection),
      apiService.getSettingsClient(),
    );
    // on ramp gateway
    gatewayDataProvider = GatewayDataProvider(
      apiService.getOnRampGatewayClient(),
    );

    addressKeyProvider =
        AddressKeyProvider(apiService.getProtonEmailAddrClient());

    serverTransactionDataProvider = ServerTransactionDataProvider(
        apiService.getWalletClient(),
        DBHelper.walletDao!,
        DBHelper.accountDao!,
        DBHelper.exchangeRateDao!,
        DBHelper.transactionDao!,
        userManager.userID);

    bdkTransactionDataProvider = BDKTransactionDataProvider(
      DBHelper.accountDao!,
      apiService,
      shared,
    );

    localBitcoinAddressDataProvider = LocalBitcoinAddressDataProvider(
      DBHelper.walletDao!,
      DBHelper.accountDao!,
      DBHelper.bitcoinAddressDao!,
      userID,
    );

    balanceDataProvider = BalanceDataProvider(
      DBHelper.accountDao!,
    );

    protonAddressProvider = ProtonAddressProvider(
      DBHelper.addressDao!,
    );

    blockInfoDataProvider = BlockInfoDataProvider(
      apiService.getBlockClient(),
    );

    exclusiveInviteDataProvider = ExclusiveInviteDataProvider(
      apiService.getInviteClient(),
    );

    protonEmailAddressProvider = ProtonEmailAddressProvider();

    connectivityProvider = ConnectivityProvider();

    final userAgent = UserAgent();
    final uid = userManager.userInfo.sessionId;
    final accessToken = userManager.userInfo.accessToken;
    unleashDataProvider = UnleashDataProvider(
      apiEnv,
      await userAgent.appVersion,
      await userAgent.ua,
      uid,
      accessToken,
    );
    // TODO(fix): fix this
    WalletManager.walletKeysProvider = walletKeysProvider;
    WalletManager.walletPassphraseProvider = walletPassphraseProvider;
    WalletManager.walletDataProvider = walletDataProvider;
    WalletManager.localBitcoinAddressDataProvider =
        localBitcoinAddressDataProvider;
    WalletManager.serverTransactionDataProvider = serverTransactionDataProvider;
    WalletManager.userID = userID;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {
    await gatewayDataProvider.clear();
    await userSettingsDataProvider.clear();
    await userDataProvider.clear();
    await walletDataProvider.clear();
    await walletPassphraseProvider.clear();
    await walletKeysProvider.clear();
    await contactsDataProvider.clear();
    await unleashDataProvider.clear();
  }
}

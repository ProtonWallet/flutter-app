import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/managers/providers/balance.data.provider.dart';
import 'package:wallet/managers/providers/bdk.transaction.data.provider.dart';
import 'package:wallet/managers/providers/server.transaction.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/models/wallet.model.dart';

// Define the events
abstract class WalletBalanceEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class NoWallet extends WalletBalanceEvent {
  NoWallet();

  @override
  List<Object> get props => [];
}

class SelectWallet extends WalletBalanceEvent {
  final WalletMenuModel walletMenuModel;

  SelectWallet(
    this.walletMenuModel,
  );

  @override
  List<Object> get props => [walletMenuModel];
}

class SelectAccount extends WalletBalanceEvent {
  final WalletMenuModel walletMenuModel;
  final AccountMenuModel accountMenuModel;

  SelectAccount(
    this.walletMenuModel,
    this.accountMenuModel,
  );

  @override
  List<Object> get props => [walletMenuModel, accountMenuModel];
}

// Define the state
class WalletBalanceState extends Equatable {
  final int balanceInSatoshi;

  const WalletBalanceState({
    required this.balanceInSatoshi,
  });

  @override
  List<Object?> get props => [
        balanceInSatoshi,
      ];
}

extension WalletTransactionStateCopyWith on WalletBalanceState {
  WalletBalanceState copyWith({
    int? balanceInSatoshi,
  }) {
    return WalletBalanceState(
      balanceInSatoshi: balanceInSatoshi ?? 0,
    );
  }
}

/// Define the Bloc
class WalletBalanceBloc extends Bloc<WalletBalanceEvent, WalletBalanceState> {
  StreamSubscription? subscription;
  StreamSubscription? subscriptionForServerTransaction;
  StreamSubscription? subscriptionForSelectedWalletChange;
  final BalanceDataProvider balanceDataProvider;
  final BDKTransactionDataProvider bdkTransactionDataProvider;
  final WalletsDataProvider walletsDataProvider;
  final ServerTransactionDataProvider serverTransactionDataProvider;

  WalletBalanceEvent? lastEvent;

  WalletBalanceBloc(
    this.bdkTransactionDataProvider,
    this.balanceDataProvider,
    this.walletsDataProvider,
    this.serverTransactionDataProvider,
  ) : super(const WalletBalanceState(
          balanceInSatoshi: 0,
        )) {
    subscriptionForSelectedWalletChange = walletsDataProvider
        .selectedWalletUpdateController.stream
        .listen((data) async {
      if (lastEvent != null) {
        if (lastEvent is SelectWallet) {
          SelectWallet selectWallet = (lastEvent as SelectWallet);
          if (walletsDataProvider.selectedServerWalletID !=
              selectWallet.walletMenuModel.walletModel.serverWalletID) {
            /// need to refresh balance when walletDataProvider's selected Wallet ID is not match to last event
            /// this case will only happened when user delete wallet
            WalletData? walletData =
                await walletsDataProvider.getWalletByServerWalletID(
                    walletsDataProvider.selectedServerWalletID);
            if (walletData != null) {
              WalletMenuModel walletMenuModel =
                  WalletMenuModel(walletData.wallet);
              walletMenuModel.accounts = walletData.accounts
                  .map((item) => AccountMenuModel(item))
                  .toList();
              add(SelectWallet(
                walletMenuModel,
              ));
            }
          }
        } else if (lastEvent is SelectAccount) {
          SelectAccount selectAccount = (lastEvent as SelectAccount);
          if (walletsDataProvider.selectedServerWalletAccountID !=
              selectAccount.accountMenuModel.accountModel.serverAccountID) {
            /// need to refresh balance when walletDataProvider's selected Wallet account ID is not match to last event
            /// this case will only happened when user delete wallet or wallet account
            if (walletsDataProvider.selectedServerWalletID != "") {
              WalletData? walletData =
                  await walletsDataProvider.getWalletByServerWalletID(
                      walletsDataProvider.selectedServerWalletID);
              if (walletData != null) {
                WalletMenuModel walletMenuModel =
                    WalletMenuModel(walletData.wallet);
                walletMenuModel.accounts = walletData.accounts
                    .map((item) => AccountMenuModel(item))
                    .toList();
                add(SelectWallet(
                  walletMenuModel,
                ));
              }
            }
          }
        }
      }
    });

    /// Listen to the data update
    subscription = bdkTransactionDataProvider.stream.listen((state) {
      if (state is BDKDataUpdated) {
        handleTransactionUpdate();
      }
    });
    subscriptionForServerTransaction = serverTransactionDataProvider
        .dataUpdateController.stream
        .listen((data) {
      handleTransactionUpdate();
    });

    on<NoWallet>((event, emit) async {
      emit(state.copyWith(
        balanceInSatoshi: 0,
      ));
    });

    on<SelectWallet>((event, emit) async {
      emit(state.copyWith(
        balanceInSatoshi: 0,
      ));
      lastEvent = event;
      int balance = 0;
      WalletModel walletModel = event.walletMenuModel.walletModel;
      for (AccountMenuModel accountMenuModel
          in event.walletMenuModel.accounts) {
        // update account balance
        BDKBalanceData bdkBalanceData =
            await balanceDataProvider.getBDKBalanceDataByWalletAccount(
          walletModel,
          accountMenuModel.accountModel,
        );
        balance += await bdkBalanceData.getBalance();
      }

      emit(state.copyWith(
        balanceInSatoshi: balance,
      ));
    });

    on<SelectAccount>((event, emit) async {
      emit(state.copyWith(
        balanceInSatoshi: 0,
      ));
      lastEvent = event;
      WalletModel walletModel = event.walletMenuModel.walletModel;
      BDKBalanceData bdkBalanceData =
          await balanceDataProvider.getBDKBalanceDataByWalletAccount(
        walletModel,
        event.accountMenuModel.accountModel,
      );
      int balance = await bdkBalanceData.getBalance();
      emit(state.copyWith(
        balanceInSatoshi: balance,
      ));
    });
  }

  void handleTransactionUpdate() {
    if (lastEvent != null) {
      if (lastEvent is SelectWallet) {
        SelectWallet selectWallet = (lastEvent as SelectWallet);
        add(SelectWallet(
          selectWallet.walletMenuModel,
        ));
      } else if (lastEvent is SelectAccount) {
        SelectAccount selectAccount = (lastEvent as SelectAccount);
        add(SelectAccount(
          selectAccount.walletMenuModel,
          selectAccount.accountMenuModel,
        ));
      }
    }
  }

  void noWallet() {
    add(NoWallet());
  }

  void selectWallet(WalletMenuModel walletMenuModel) {
    add(SelectWallet(
      walletMenuModel,
    ));
  }

  void selectAccount(
    WalletMenuModel walletMenuModel,
    AccountMenuModel accountMenuModel,
  ) {
    add(SelectAccount(
      walletMenuModel,
      accountMenuModel,
    ));
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    subscriptionForServerTransaction?.cancel();
    subscriptionForSelectedWalletChange?.cancel();
    return super.close();
  }
}

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
  StreamSubscription? bdkTransactionDataSubscription;
  StreamSubscription? serverTransactionDataSubscription;
  StreamSubscription? selectedWalletChangeSubscription;
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
    selectedWalletChangeSubscription = walletsDataProvider
        .selectedWalletUpdateController.stream
        .listen((data) async {
      WalletData? walletData =
          await walletsDataProvider.getWalletByServerWalletID(
              walletsDataProvider.selectedServerWalletID);
      if (walletData != null) {
        WalletMenuModel walletMenuModel = WalletMenuModel(walletData.wallet);
        walletMenuModel.accounts =
            walletData.accounts.map((item) => AccountMenuModel(item)).toList();
        if (walletsDataProvider.selectedServerWalletAccountID.isEmpty) {
          /// wallet view
          add(SelectWallet(
            walletMenuModel,
          ));
        } else {
          /// wallet account view
          for (AccountMenuModel accountMenuModel in walletMenuModel.accounts) {
            if (accountMenuModel.accountModel.accountID ==
                walletsDataProvider.selectedServerWalletAccountID) {
              add(SelectAccount(
                walletMenuModel,
                accountMenuModel,
              ));
              break;
            }
          }
        }
      } else {
        /// no wallets
        /// clear all
        add(NoWallet());
      }
    });

    /// Listen to the data update
    bdkTransactionDataSubscription =
        bdkTransactionDataProvider.dataUpdateController.stream.listen((state) {
      handleTransactionUpdate();
    });
    serverTransactionDataSubscription = serverTransactionDataProvider
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
    bdkTransactionDataSubscription?.cancel();
    serverTransactionDataSubscription?.cancel();
    selectedWalletChangeSubscription?.cancel();
    return super.close();
  }
}

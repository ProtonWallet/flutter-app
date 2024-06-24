import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/managers/providers/balance.data.provider.dart';
import 'package:wallet/managers/providers/bdk.transaction.data.provider.dart';
import 'package:wallet/models/wallet.model.dart';

// Define the events
abstract class WalletBalanceEvent extends Equatable {
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
  final BalanceDataProvider balanceDataProvider;
  final BDKTransactionDataProvider bdkTransactionDataProvider;

  WalletBalanceEvent? lastEvent;

  WalletBalanceBloc(
    this.bdkTransactionDataProvider,
    this.balanceDataProvider,
  ) : super(const WalletBalanceState(
          balanceInSatoshi: 0,
        )) {
    /// Listen to the data update
    subscription = bdkTransactionDataProvider.stream.listen((state) {
      if (state is BDKDataUpdated) {
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
    });

    on<SelectWallet>((event, emit) async {
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
    return super.close();
  }
}

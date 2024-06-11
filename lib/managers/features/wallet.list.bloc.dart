import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/managers/features/models/wallet.list.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.passphrase.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';

// Define the events
abstract class WalletListEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class SelectWallet extends WalletListEvent {
  final WalletModel walletModel;
  SelectWallet(this.walletModel);

  @override
  List<Object> get props => [walletModel];
}

class StartLoading extends WalletListEvent {
  StartLoading();

  @override
  List<Object> get props => [];
}

class SelectAccount extends WalletListEvent {
  final WalletModel walletModel;
  final AccountModel accountModel;
  SelectAccount(this.walletModel, this.accountModel);

  @override
  List<Object> get props => [walletModel, accountModel];
}

// Define the state
class WalletListState extends Equatable {
  final bool initialized;
  final List<WalletMenuModel> walletsModel;
  final WalletModel? currentWallet;
  final AccountModel? currentAccount;

  const WalletListState({
    required this.initialized,
    required this.walletsModel,
    this.currentWallet,
    this.currentAccount,
  });

  @override
  List<Object?> get props =>
      [initialized, walletsModel, currentWallet, currentAccount];
}

extension WalletListStateCopyWith on WalletListState {
  WalletListState copyWith({
    bool? initialized,
    List<WalletMenuModel>? walletsModel,
    WalletModel? currentWallet,
    AccountModel? currentAccount,
  }) {
    return WalletListState(
      initialized: initialized ?? this.initialized,
      walletsModel: walletsModel ?? this.walletsModel,
      currentWallet: currentWallet ?? this.currentWallet,
      currentAccount: currentAccount ?? this.currentAccount,
    );
  }
}

// Define the Bloc
class WalletListBloc extends Bloc<WalletListEvent, WalletListState> {
  final WalletsDataProvider walletsDataProvider;
  final WalletPassphraseProvider walletPassProvider;
  final WalletKeysProvider walletKeysProvider;
  final UserManager userManager;
  WalletListBloc(
    this.walletsDataProvider,
    this.walletPassProvider,
    this.walletKeysProvider,
    this.userManager,
  ) : super(const WalletListState(
            initialized: false,
            walletsModel: [],
            currentWallet: null,
            currentAccount: null)) {
    on<StartLoading>((event, emit) async {
      // loading wallet data
      var wallets = await walletsDataProvider.getWallets();
      if (wallets == null) {
        emit(state.copyWith(initialized: true));
        return; // error;
      }
      List<WalletMenuModel> walletsModel = [];
      for (WalletData wallet in wallets) {
        // check if wallet has password valid. no password is valid
        WalletMenuModel walletModel = WalletMenuModel();

        walletModel.hasValidPassword =
            await _hasValidPassphrase(wallet.wallet, walletPassProvider);
        // var firstKey = userManager.getFirstKey();
        walletModel.walletName = wallet.wallet.name;
        walletModel.accountSize = wallet.accounts.length;

        walletsModel.add(walletModel);
      }
      // for (var wallet in walletsList) {
      //   // check if wallet has password valid. no password is valid
      //   Future<bool> hasValidPassphrase(WalletModel wallet,
      //       WalletPassphraseProvider walletPassProvider) async {
      //     // Check if the wallet requires a passphrase and if the passphrase is valid
      //     if (wallet.passphrase == 1) {
      //       final passphrase = await walletPassProvider.getWalletPassphrase(
      //         wallet.serverWalletID,
      //       );
      //       return passphrase != null;
      //     }
      //     // Default to false if none of the above conditions are met
      //     return true;
      //   }

      //   // check passwords
      //   wallet.hasValidPassword = await hasValidPassphrase(
      //     wallet.wallet,
      //     walletPassProvider,
      //   );
      // }
      emit(state.copyWith(initialized: true, walletsModel: walletsModel));
      // select first
      var firstWallet = wallets.first;
      var firstAccount = firstWallet.accounts.first;
      emit(state.copyWith(
        currentWallet: firstWallet.wallet,
        currentAccount: firstAccount,
      ));
    });
  }

  void init() {
    add(StartLoading());
  }

  Future<bool> _hasValidPassphrase(
    WalletModel wallet,
    WalletPassphraseProvider walletPassProvider,
  ) async {
    // Check if the wallet requires a passphrase and if the passphrase is valid
    if (wallet.passphrase == 1) {
      final passphrase = await walletPassProvider.getWalletPassphrase(
        wallet.serverWalletID,
      );
      return passphrase != null;
    }
    // Default to false if none of the above conditions are met
    return true;
  }
}

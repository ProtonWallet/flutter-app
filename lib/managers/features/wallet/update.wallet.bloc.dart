import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.passphrase.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';

// Define the events
abstract class UpateWalletEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Define the state
class UpdateWalletState extends Equatable {
  @override
  List<Object?> get props => [];
}

extension CreatingWalletState on UpdateWalletState {}

extension AddingEmailState on UpdateWalletState {}

/// Define the Bloc
class UpdateWalletBloc extends Bloc<UpateWalletEvent, UpdateWalletState> {
  final UserManager userManager;
  final WalletKeysProvider walletKeysProvider;
  final WalletsDataProvider walletsDataProvider;
  final WalletPassphraseProvider walletPassphraseProvider;

  /// initialize the bloc with the initial state
  UpdateWalletBloc(
    this.userManager,
    this.walletsDataProvider,
    this.walletKeysProvider,
    this.walletPassphraseProvider,
  ) : super(UpdateWalletState()) {
    on<UpateWalletEvent>((event, emit) async {
      /// start update wallet check.
      ///  notes: wallet, wallet account, transaction labels
      /// 1. get wallets from current cache
      /// 2. check if wallet data need to be update
      /// 3. fetch late wallet data from server
      /// 4. update wallet data
      /// 5. fetch transactions meta data
      /// 6. decrypt and encrypted it
      /// 7. update wallet data to cache
      ///
    });
  }
}

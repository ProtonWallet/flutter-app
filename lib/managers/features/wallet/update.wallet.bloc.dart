import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/providers/address.keys.provider.dart';
import 'package:wallet/managers/providers/server.transaction.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.mnemonic.provider.dart';
import 'package:wallet/managers/providers/wallet.name.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/api/proton_wallet/crypto/wallet_key_helper.dart';
import 'package:wallet/rust/api/proton_wallet/features/transition_layer.dart';
import 'package:wallet/rust/proton_api/wallet.dart';

// Define the events
abstract class UpateWalletEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class MigrateWalletEvent extends UpateWalletEvent {}

// Define the state
class UpdateWalletState extends Equatable {
  @override
  List<Object?> get props => [];
}

extension CreatingWalletState on UpdateWalletState {}

extension AddingEmailState on UpdateWalletState {}

/// Define the Bloc
class UpdateWalletBloc extends Bloc<UpateWalletEvent, UpdateWalletState> {
  final WalletsDataProvider walletsDataProvider;
  final ServerTransactionDataProvider serverTransactionDataProvider;
  final AddressKeyProvider addressKeyProvider;
  final WalletKeysProvider walletKeysProvider;
  final WalletNameProvider walletNameProvider;
  final WalletMnemonicProvider walletMnemonicProvider;
  final WalletClient walletClient;

  ///
  final UserManager userManager;

  /// initialize the bloc with the initial state
  UpdateWalletBloc(
    this.userManager,
    this.walletsDataProvider,
    this.walletKeysProvider,
    this.walletNameProvider,
    this.walletMnemonicProvider,
    this.walletClient,
    this.serverTransactionDataProvider,
    this.addressKeyProvider,
  ) : super(UpdateWalletState()) {
    ///  notes: wallet, wallet account, transaction labels
    /// 1. get wallets from current cache
    /// 2. check if wallet data need to be update
    /// 3. fetch late wallet data from server
    /// 4. update wallet data
    /// 5. fetch transactions meta data
    /// 6. decrypt and encrypted it
    /// 7. update wallet data to cache
    on<MigrateWalletEvent>((event, emit) async {
      /// 1. get wallets from current cache
      final wallets = await walletsDataProvider.getWallets();
      if (wallets == null || wallets.isEmpty) {
        return;
      }
      for (final wallet in wallets) {
        /// 2. check if wallet data need to be update
        if (wallet.wallet.migrationRequired == 1) {
          try {
            final walletId = wallet.wallet.walletID;
            final clearWalletName = await walletNameProvider.getNameWithID(
              walletId,
            );
            final clearMnemonic =
                await walletMnemonicProvider.getMnemonicWithID(walletId);

            /// Generate a wallet secret key
            final unlockedWalletKey = FrbWalletKeyHelper.generateSecretKey();

            /// encrypt wallet name with wallet key
            final encryptedWalletName = FrbWalletKeyHelper.encrypt(
              base64SecureKey: unlockedWalletKey.toBase64(),
              plaintext: clearWalletName,
            );

            /// encrypt mnemonic with wallet key
            final encryptedMnemonic = FrbWalletKeyHelper.encrypt(
              base64SecureKey: unlockedWalletKey.toBase64(),
              plaintext: clearMnemonic,
            );

            /// get first user key (primary user key)
            final primaryUserKey = await userManager.getPrimaryKeyForTL();
            final passphrase = userManager.getUserKeyPassphrase();

            final encryptedWalletKey = FrbTransitionLayer.encryptWalletKey(
                walletKey: unlockedWalletKey,
                userKey: primaryUserKey,
                userKeyPassphrase: passphrase);

            /// encrypt wallet key with user private key
            final String encryptedArmoredWalletKey =
                encryptedWalletKey.getArmored();

            /// sign wallet key with user private key
            final String walletKeySignature = encryptedWalletKey.getSignature();

            ///update wallet, account, transactions data

            ///migrate wallet data
            final migratedWallet = MigratedWallet(
              name: encryptedWalletName,
              userKeyId: primaryUserKey.id,
              walletKey: encryptedArmoredWalletKey,
              walletKeySignature: walletKeySignature,
              mnemonic: encryptedMnemonic,
              // shouldnt be null
              fingerprint: wallet.wallet.fingerprint ?? "",
            );

            ///migrate wallet account data
            final List<MigratedWalletAccount> migratedWalletAccounts = [];
            for (final account in wallet.accounts) {
              final clearLabel = await walletNameProvider.getAccountLabelWithID(
                account.accountID,
              );
              final encryptedLabel = FrbWalletKeyHelper.encrypt(
                  base64SecureKey: unlockedWalletKey.toBase64(),
                  plaintext: clearLabel);

              final migratedWalletAccount = MigratedWalletAccount(
                id: account.accountID,
                label: encryptedLabel,
              );
              migratedWalletAccounts.add(migratedWalletAccount);
            }

            /// migrate transactions
            final List<MigratedWalletTransaction> migratedWalletTransactions =
                [];
            final walletTransactions = await walletClient.getWalletTransactions(
              walletId: walletId,
            );

            /// decrypt transaction id
            final userKeys = await userManager.getUserKeysForTL();
            final addrKeys = await addressKeyProvider.getAddressKeysForTL();
            final userKeyPassword = userManager.getUserKeyPassphrase();

            final oldUnlockedWalletKey =
                await walletKeysProvider.getWalletSecretKey(walletId);

            for (final transaction in walletTransactions) {
              final accountID = transaction.walletAccountId;
              if (accountID == null) {
                return;
              }

              // decrypt label
              final label = transaction.label;
              String? encryptedLabel;
              if (label != null && label.isNotEmpty) {
                final clearLabel = FrbWalletKeyHelper.decrypt(
                  base64SecureKey: oldUnlockedWalletKey.toBase64(),
                  encryptText: label,
                );
                encryptedLabel = FrbWalletKeyHelper.encrypt(
                  base64SecureKey: unlockedWalletKey.toBase64(),
                  plaintext: clearLabel,
                );
              }

              final encryptedTransactionID = transaction.transactionId;
              final txid = FrbTransitionLayer.decryptTransactionId(
                  userKeys: userKeys,
                  addrKeys: addrKeys,
                  userKeyPassword: userKeyPassword,
                  encTransactionId: encryptedTransactionID);

              final primaryUserKey = await userManager.getPrimaryKeyForTL();
              final transactionId =
                  FrbTransitionLayer.encryptMessagesWithUserkey(
                      userKey: primaryUserKey, message: txid);

              /// hash transaction id
              final hashedTransID = await WalletKeyHelper.getHmacHashedString(
                unlockedWalletKey,
                txid,
              );

              /// pack migrated data
              final migratedWalletTransaction = MigratedWalletTransaction(
                id: transactionId,
                walletAccountId: accountID,
                hashedTransactionId: hashedTransID,
                label: encryptedLabel ?? "",
              );
              migratedWalletTransactions.add(migratedWalletTransaction);
            }

            /// 7. update wallet data to cache

            await walletClient.migrate(
              walletId: walletId,
              migratedWallet: migratedWallet,
              migratedWalletAccounts: migratedWalletAccounts,
              migratedWalletTransactions: migratedWalletTransactions,
            );

            /// no error then date local cache
            await walletKeysProvider.reset();
            await walletsDataProvider.reset();
            await serverTransactionDataProvider.reset(walletId);
          } catch (e, stacktrace) {
            logger.e(
              "getHistoryTransactions error: $e stacktrace: $stacktrace",
            );
          }
        }
      }
    });
  }
}

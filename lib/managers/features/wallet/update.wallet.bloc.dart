import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:sentry/sentry.dart';
import 'package:wallet/helper/extension/data.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/features/wallet/wallet.dart';
import 'package:wallet/managers/providers/address.keys.provider.dart';
import 'package:wallet/managers/providers/server.transaction.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
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
  final WalletClient walletClient;

  ///
  final UserManager userManager;

  /// initialize the bloc with the initial state
  UpdateWalletBloc(
    this.userManager,
    this.walletsDataProvider,
    this.walletKeysProvider,
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
        /// check if wallet data need to be update
        if (wallet.wallet.migrationRequired == 1) {
          try {
            final walletId = wallet.wallet.walletID;
            final secretKey = await walletKeysProvider.getWalletSecretKey(
              walletId,
            );

            final walletMnemonic = await walletsDataProvider.getWalletMnemonic(
              walletId,
            );
            if (walletMnemonic == null) {
              return;
            }

            /// get first user key (primary user key)
            final primaryUserKey = await userManager.getPrimaryKey();

            /// Generate a wallet secret key
            final newSecretKey = WalletKeyHelper.generateSecretKey();

            ///update wallet, account, transactions data
            ///
            ///migrate wallet data
            final migratedWallet = await ProtonWallet.migrateWalletData(
                primaryUserKey,
                secretKey,
                newSecretKey,
                wallet.wallet.name,
                walletMnemonic.mnemonic,
                wallet.wallet.fingerprint ?? "");

            ///migrate wallet account data
            final List<MigratedWalletAccount> migratedWalletAccounts = [];
            for (final account in wallet.accounts) {
              final clearLabel = await WalletKeyHelper.decrypt(
                secretKey,
                account.label.base64encode(),
              );

              final encryptedLabel = await WalletKeyHelper.encrypt(
                newSecretKey,
                clearLabel,
              );
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
            for (final transaction in walletTransactions) {
              final accountID = transaction.walletAccountId;
              if (accountID == null) {
                return;
              }

              // decrypt label
              final label = transaction.label;
              String? encryptedLabel;
              if (label != null && label.isNotEmpty) {
                final clearLabel = await WalletKeyHelper.decrypt(
                  secretKey,
                  label,
                );
                encryptedLabel = await WalletKeyHelper.encrypt(
                  newSecretKey,
                  clearLabel,
                );
              }

              /// decrypt transaction id
              final addressKeys = await addressKeyProvider.getAddressKeys();
              final userKeys = await userManager.getUserKeys();
              final encryptedTransactionID = transaction.transactionId;
              String txid = "";
              for (final uKey in userKeys) {
                try {
                  txid = proton_crypto.decrypt(
                    uKey.privateKey,
                    uKey.passphrase,
                    encryptedTransactionID,
                  );
                  break;
                } catch (e, stacktrace) {
                  logger.i(
                    "MigrateWalletEvent error: $e stacktrace: $stacktrace",
                  );
                }
              }
              if (txid.isEmpty) {
                for (final addressKey in addressKeys) {
                  try {
                    txid = addressKey.decrypt(encryptedTransactionID);
                  } catch (e, stacktrace) {
                    logger.e(
                      "MigrateWalletEvent error: $e stacktrace: $stacktrace",
                    );
                  }
                  if (txid.isNotEmpty) {
                    break;
                  }
                }
              }

              /// hash transaction id
              final hashedTransID = txid.isNotEmpty
                  ? await WalletKeyHelper.getHmacHashedString(
                      newSecretKey,
                      txid,
                    )
                  : null;

              /// pack migrated data
              final migratedWalletTransaction = MigratedWalletTransaction(
                id: transaction.id,
                walletAccountId: accountID,
                hashedTransactionId: hashedTransID,
                label: encryptedLabel,
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
            Sentry.captureException(
              e,
              stackTrace: stacktrace,
            );
            logger.e(
              "MigrateWalletEvent error: $e stacktrace: $stacktrace",
            );
          }
        }
      }
    });
  }
}

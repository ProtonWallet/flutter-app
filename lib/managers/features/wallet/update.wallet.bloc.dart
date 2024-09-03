import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/constants/constants.dart';
import 'package:wallet/helper/extension/data.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/providers/address.keys.provider.dart';
import 'package:wallet/managers/providers/server.transaction.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.passphrase.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/proton_api/wallet.dart';

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
  final WalletsDataProvider walletsDataProvider;
  final ServerTransactionDataProvider serverTransactionDataProvider;
  final AddressKeyProvider addressKeyProvider;
  final WalletClient walletClient;

  ///
  final UserManager userManager;
  final WalletKeysProvider walletKeysProvider;
  final WalletPassphraseProvider walletPassphraseProvider;

  /// initialize the bloc with the initial state
  UpdateWalletBloc(
    this.userManager,
    this.walletsDataProvider,
    this.walletKeysProvider,
    this.walletPassphraseProvider,
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
    on<UpateWalletEvent>((event, emit) async {
      /// 1. get wallets from current cache
      final wallets = await walletsDataProvider.getWallets();
      if (wallets == null || wallets.isEmpty) {
        // TODO(log): add log
        return;
      }
      for (final wallet in wallets) {
        /// 2. check if wallet data need to be update
        if (wallet.wallet.migrationRequired == 1) {
          final walletId = wallet.wallet.walletID;
          final walletKey = await walletKeysProvider.getWalletKey(walletId);
          if (walletKey == null) {
            // TODO(log): add log
            return;
          }

          final userKey = await userManager.getUserKey(walletKey.userKeyId);
          final secretKey = WalletKeyHelper.decryptWalletKey(
            userKey,
            walletKey,
          );

          final clearWalletName = await WalletKeyHelper.decrypt(
            secretKey,
            wallet.wallet.name,
          );

          final clearMnemonic = await WalletKeyHelper.decrypt(
            secretKey,
            wallet.wallet.mnemonic.base64encode(),
          );

          /// Generate a wallet secret key
          final newSecretKey = WalletKeyHelper.generateSecretKey();
          final entropy = Uint8List.fromList(await secretKey.extractBytes());

          /// get first user key (primary user key)
          final primaryUserKey = await userManager.getPrimaryKey();
          final String userPrivateKey = primaryUserKey.privateKey;
          final String userKeyID = primaryUserKey.keyID;
          final String passphrase = primaryUserKey.passphrase;

          /// encrypt wallet name with wallet key
          final String encryptedWalletName = await WalletKeyHelper.encrypt(
            newSecretKey,
            clearWalletName,
          );

          /// encrypt mnemonic with wallet key
          final String encryptedMnemonic = await WalletKeyHelper.encrypt(
            newSecretKey,
            clearMnemonic,
          );

          /// encrypt wallet key with user private key
          final String encryptedWalletKey = proton_crypto.encryptBinaryArmor(
            userPrivateKey,
            entropy,
          );

          /// sign wallet key with user private key
          final String walletKeySignature =
              proton_crypto.getBinarySignatureWithContext(
            userPrivateKey,
            passphrase,
            entropy,
            gpgContextWalletKey,
          );

          ///update wallet, account, transactions data

          ///migrate wallet data
          final migratedWallet = MigratedWallet(
            name: encryptedWalletName,
            userKeyId: userKeyID,
            walletKey: encryptedWalletKey,
            walletKeySignature: walletKeySignature,
            mnemonic: encryptedMnemonic,
            // shouldnt be null
            fingerprint: wallet.wallet.fingerprint ?? "",
          );

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
          final List<MigratedWalletTransaction> migratedWalletTransactions = [];
          final walletTransactions = await walletClient.getWalletTransactions(
            walletId: walletId,
          );
          for (final transaction in walletTransactions) {
            final accountID = transaction.walletAccountId;
            if (accountID == null) {
              // TODO(log): add log
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
                  "getHistoryTransactions error: $e stacktrace: $stacktrace",
                );
              }
            }
            if (txid.isEmpty) {
              for (final addressKey in addressKeys) {
                try {
                  txid = addressKey.decrypt(encryptedTransactionID);
                } catch (e, stacktrace) {
                  logger.e(
                    "getHistoryTransactions error: $e stacktrace: $stacktrace",
                  );
                }
                if (txid.isNotEmpty) {
                  break;
                }
              }
            }

            /// hash transaction id
            final hashedTransID = await WalletKeyHelper.getHmacHashedString(
              newSecretKey,
              txid,
            );

            /// pack migrated data
            final migratedWalletTransaction = MigratedWalletTransaction(
              id: transaction.id,
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
        }
      }
    });
  }
}

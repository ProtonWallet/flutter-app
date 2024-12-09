import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/providers/models/wallet.key.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/models/wallet.keys.store.dart';
import 'package:wallet/rust/api/proton_wallet/features/proton_recovery.dart';
import 'package:wallet/rust/api/proton_wallet/storage/user_key_store.dart';
import 'package:wallet/rust/api/proton_wallet/storage/wallet_key_store.dart';
import 'package:wallet/rust/api/proton_wallet/storage/wallet_mnemonic_store.dart';
import 'package:wallet/rust/api/proton_wallet/wallet.dart';

class ProtonWalletManager implements Manager {
  /// instance of secure storage for rust callbacks
  late FrbWalletKeyStore frbWalletKeyStore;
  late FrbUserKeyStore frbUserKeyStore;
  late FrbWalletMnemonicStore frbWalletMnemonicStore;

  /// proton wallet
  late FrbProtonWallet protonWallet;

  /// instance for dart
  late WalletKeyStore walletKeyStore;
  final ProtonApiServiceManager apiManager;
  final SecureStorageManager storage;
  final String dbPath;
  final UserManager userManager;

  ProtonWalletManager(
    this.apiManager,
    this.storage,
    this.userManager,
    this.dbPath,
  );

  @override
  Future<void> init() async {
    /// init user key store and set callbacks
    frbUserKeyStore = FrbUserKeyStore();
    await frbUserKeyStore.setGetDefaultUserKeyCallback(
        callback: (userID) async {
      logger.d("ProtonWalletManager: get default user key");
      final userKey = await userManager.getDefaultKey();
      return userKey;
    });
    await frbUserKeyStore.setGetPassphraseCallback(callback: (userID) async {
      logger.d("ProtonWalletManager: get default user key passphrase");
      final userKey = await userManager.getPrimaryKey();
      return userKey.passphrase;
    });

    /// init wallet key store and set callbacks
    frbWalletKeyStore = FrbWalletKeyStore();
    await frbWalletKeyStore.setGetWalletKeysCallback(callback: () async {
      logger.d("ProtonWalletManager: get walelt keys");
      final walletKeys = await walletKeyStore.getWalletKeys();
      if (walletKeys == null) {
        return [];
      }
      final apiWalletKeys = WalletKey.toApiWalletKeys(walletKeys);
      return apiWalletKeys;
    });
    await frbWalletKeyStore.setSaveWalletKeysCallback(callback: (keys) async {
      logger.d("ProtonWalletManager: save walelt keys");
      final walletKeys = WalletKey.fromApiWalletKeys(keys);
      await walletKeyStore.saveWalletKeys(walletKeys);
    });

    /// init wallet mnemonic store and set callbacks
    frbWalletMnemonicStore = FrbWalletMnemonicStore();
    await frbWalletMnemonicStore.setGetWalletKeysCallback(callback: () async {
      logger.d("ProtonWalletManager: get mnemonic ");
      return [];
    });
    await frbWalletMnemonicStore.setSaveWalletKeysCallback(
      callback: (mnemonics) async {
        logger.d("ProtonWalletManager: set mnemonic ");
      },
    );
    final databasePath = '$dbPath/proton_wallet_rust_db.sqlite';
    protonWallet = await FrbProtonWallet.newInstance(
        dbPath: databasePath,
        userKeyTore: frbUserKeyStore,
        walletKeyStore: frbWalletKeyStore,
        walletMnemonicStore: frbWalletMnemonicStore);
  }

  /// ==============================
  @override
  Future<void> dispose() async {}
  @override
  Future<void> login(String userID) async {}

  /// wallet creation feature
  // Future<FrbWalletCreation> getWalletCrateionFeature() async {
  //   return protonWallet.getWalletCrateionFeature();
  // }

  /// get backup mnemonic feature
  // Future<FrbBackupMnemonic> getBackupMnemonicFeature() async {
  //   return protonWallet.getBackupMnemonicFeature();
  // }

  /// get recovery feature
  FrbProtonRecovery getProtonRecoveryFeature() {
    return protonWallet.getProtonRecoveryFeature();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> reload() async {}

  @override
  Priority getPriority() {
    return Priority.level5;
  }
}

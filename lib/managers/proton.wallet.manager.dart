import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/providers/models/wallet.key.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/models/wallet.keys.store.dart';
// import 'package:wallet/rust/api/proton_wallet/features/backup_mnemonic.dart';
import 'package:wallet/rust/api/proton_wallet/storage/user_key_store.dart';
import 'package:wallet/rust/api/proton_wallet/storage/wallet_key_store.dart';
import 'package:wallet/rust/api/proton_wallet/storage/wallet_mnemonic_store.dart';
// import 'package:wallet/rust/api/proton_wallet/wallet.dart';

class ProtonWalletManager implements Manager {
  /// instance of secure storage for rust callbacks
  late FrbWalletKeyStore frbWalletKeyStore;
  late FrbUserKeyStore frbUserKeyStore;
  late FrbWalletMnemonicStore frbWalletMnemonicStore;

  /// proton wallet
  // late FrbProtonWallet protonWallet;

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
    frbUserKeyStore = FrbUserKeyStore();
    frbWalletKeyStore = FrbWalletKeyStore();
    frbWalletMnemonicStore = FrbWalletMnemonicStore();
  }

  /// ==============================
  @override
  Future<void> dispose() async {}
  @override
  Future<void> login(String userID) async {
    // init wallet key store and set callbacks
    frbWalletKeyStore = FrbWalletKeyStore();
    frbWalletKeyStore.setGetWalletKeysCallback(callback: () async {
      final walletKeys = await walletKeyStore.getWalletKeys();
      if (walletKeys == null) {
        return [];
      }
      final apiWalletKeys = WalletKey.toApiWalletKeys(walletKeys);
      return apiWalletKeys;
    });
    frbWalletKeyStore.setSaveWalletKeysCallback(callback: (keys) async {
      final walletKeys = WalletKey.fromApiWalletKeys(keys);
      await walletKeyStore.saveWalletKeys(walletKeys);
    });

    // init user keys store and set callbacks
    frbUserKeyStore = FrbUserKeyStore();
    frbUserKeyStore.setGetDefaultUserKeyCallback(callback: (userID) async {
      final userKey = await userManager.getDefaultKey();
      return userKey;
    });
    frbUserKeyStore.setGetPassphraseCallback(callback: (userID) async {
      final userKey = await userManager.getPrimaryKey();
      return userKey.passphrase;
    });

    // init wallet mnemonic store and set callbacks
    frbWalletMnemonicStore = FrbWalletMnemonicStore();
    frbWalletMnemonicStore.setGetWalletKeysCallback(callback: () async {
      return [];
    });
    frbWalletMnemonicStore.setSaveWalletKeysCallback(
        callback: (mnemonics) async {});

    // final api = apiManager.getApiService().getArc();
    // final databasePath = '$dbPath/proton_wallet_rust_db.sqlite';
    // protonWallet = await FrbProtonWallet.newInstance(
    //     api: api,
    //     dbPath: databasePath,
    //     userKeyTore: frbUserKeyStore,
    //     walletKeyStore: frbWalletKeyStore,
    //     walletMnemonicStore: frbWalletMnemonicStore);
  }

  /// wallet creation feature
  // Future<FrbWalletCreation> getWalletCrateionFeature() async {
  //   return protonWallet.getWalletCrateionFeature();
  // }

  /// get backup mnemonic feature
  // Future<FrbBackupMnemonic> getBackupMnemonicFeature() async {
  //   return protonWallet.getBackupMnemonicFeature();
  // }

  @override
  Future<void> logout() async {}

  @override
  Future<void> reload() async {}
}

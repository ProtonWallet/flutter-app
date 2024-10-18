import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/providers/models/wallet.key.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/models/wallet.keys.store.dart';
import 'package:wallet/rust/api/proton_wallet/features/wallet_creation.dart';
import 'package:wallet/rust/api/proton_wallet/storage/user_key_store.dart';
import 'package:wallet/rust/api/proton_wallet/storage/wallet_key_store.dart';
import 'package:wallet/rust/api/proton_wallet/wallet.dart';

class ProtonWalletManager implements Manager {
  /// instance for rust
  late FrbWalletKeyStore frbWalletKeyStore;
  late FrbUserKeyStore userKeyStore;
  late FrbProtonWallet protonWallet;

  /// instance for dart
  late WalletKeyStore walletKeyStore;
  final ProtonApiServiceManager apiManager;
  final SecureStorageManager storage;

  /// constructor
  ProtonWalletManager(
    this.apiManager,
    this.storage,
  );

  @override
  Future<void> init() async {
    userKeyStore = FrbUserKeyStore();
    frbWalletKeyStore = FrbWalletKeyStore();
    // protonWallet = FrbProtonWallet();
  }

  /// ==============================
  @override
  Future<void> dispose() async {}

  @override
  Future<void> login(String userID) async {
    /// login must to create late instances
    frbWalletKeyStore = FrbWalletKeyStore();
    frbWalletKeyStore.setGetWalletKeysCallback(callback: () async {
      final walletKeys = await walletKeyStore.getWalletKeys();
      if (walletKeys == null) {
        return [];
      }
      final apiWalletKeys = WalletKey.toApiWalletKeys(walletKeys);
      return apiWalletKeys;
    });

    // add FrbProtonWallet init from here
    // protonWallet = FrbProtonWallet();
  }

  Future<FrbWalletCreation> getWalletCrateionFeature() async {
    return protonWallet.getWalletCrateionFeature();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> reload() async {}
}

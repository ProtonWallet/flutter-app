import 'dart:async';

import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/models/wallet.key.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/models/wallet.keys.store.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/api/proton_wallet/crypto/wallet_key.dart';
import 'package:wallet/rust/api/proton_wallet/features/transition_layer.dart';
import 'package:wallet/rust/proton_api/wallet.dart';

class WalletKeysProvider extends DataProvider {
  /// manager
  final UserManager userManager;

  /// key store
  final WalletKeyStore walletKeyStore;

  /// api client
  final WalletClient walletClient;

  /// memory caches
  List<WalletKey>? walletKeys;

  WalletKeysProvider(
    this.userManager,
    this.walletKeyStore,
    this.walletClient,
  );

  /// trying to get wallet key from secure store and decrypt it use userKey
  Future<FrbUnlockedWalletKey> getWalletSecretKey(String serverWalletID) async {
    final walletKey = await getWalletKey(serverWalletID);
    if (walletKey == null) {
      throw Exception("Wallet key not found");
    }

    final userKey = await userManager.getUserKeyForTL(walletKey.userKeyId);
    final passphrase = userManager.getUserKeyPassphrase();

    final frbUnlockedWalletKey = FrbTransitionLayer.decryptWalletKey(
        walletKey: walletKey.toApiWalletKey(),
        userKey: userKey,
        userKeyPassphrase: passphrase);

    return frbUnlockedWalletKey;
  }

  Future<WalletKey?> getWalletKey(String walletID) async {
    /// try find from cache
    var walletKey = _findFromMemory(walletID);
    if (walletKey != null) {
      return walletKey;
    }

    /// reload from wallet store (secure storage) and update cache
    walletKeys = await _getWalletKeys();
    walletKey = _findFromMemory(walletID);
    if (walletKey != null) {
      return walletKey;
    }

    /// fetch from server if we cannot find in cache and secure storage
    await _fetchFromServer();

    walletKeys = await _getWalletKeys();
    return _findFromMemory(walletID);
  }

  /// find from memory cache
  WalletKey? _findFromMemory(String walletID) {
    if (walletKeys != null) {
      final key = walletKeys
          ?.where((key) => key.walletId == walletID)
          .toList()
          .firstOrNull;
      return key;
    }
    return null;
  }

  /// fetch from server
  Future<void> _fetchFromServer() async {
    final apiWallets = await walletClient.getWallets();
    final apiWalletKeys = apiWallets.map((e) => e.walletKey).toList();
    await saveApiWalletKeys(apiWalletKeys);
  }

  /// fetch from local cache
  Future<List<WalletKey>?> _getWalletKeys() async {
    if (walletKeys != null) {
      return walletKeys!;
    }
    walletKeys = await walletKeyStore.getWalletKeys();
    if (walletKeys != null) {
      return walletKeys!;
    }
    return null;
  }

  /// save the wallet key to local cache, and refresh the memery cache
  Future<void> saveWalletKeys(List<WalletKey> keys) async {
    if (keys.isEmpty) {
      logger.e("walle keys is empty");
      return;
    }

    final Map<String, WalletKey> mergedMap = {};
    if (walletKeys != null) {
      /// Insert items from list1 first
      for (var key in walletKeys ?? []) {
        mergedMap[key.walletId] = key;
      }
    }

    for (var key in keys) {
      mergedMap[key.walletId] = key;
    }

    walletKeys = mergedMap.values.toList();
    await walletKeyStore.saveWalletKeys(keys);
  }

  /// save data to walletKey store (secure storage)
  Future<void> saveApiWalletKeys(List<ApiWalletKey> items) async {
    final keys = WalletKey.fromApiWalletKeys(items);
    saveWalletKeys(keys);
  }

  @override
  Future<void> clear() async {
    walletKeys = null;
  }

  Future<void> reset() async {
    walletKeys = null;
    await _fetchFromServer();
  }

  @override
  Future<void> reload() async {}
}

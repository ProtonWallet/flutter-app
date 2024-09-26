import 'dart:async';

import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/models/wallet.key.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';

class WalletKeyStore {
  final SecureStorageManager storage;
  final key = "proton_wallet_k_provider_key";

  WalletKeyStore(this.storage);

  /// fetch from local cache
  Future<List<WalletKey>?> getWalletKeys() async {
    final json = await storage.get(key);
    if (json.isEmpty) {
      return null;
    }
    return WalletKey.loadJsonString(json);
  }

  /// save the wallet key to local cache, and refresh the memery cache
  Future<void> saveWalletKeys(List<WalletKey> keys) async {
    if (keys.isEmpty) {
      logger.e("walle keys is empty");
      return;
    }
    final jsonString = WalletKey.toJsonString(keys);
    await storage.set(key, jsonString);
  }
}

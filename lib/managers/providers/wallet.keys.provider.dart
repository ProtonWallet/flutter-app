import 'dart:async';

import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/models/wallet.key.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/proton_api/wallet.dart';

class WalletKeysProvider extends DataProvider {
  final SecureStorageManager storage;
  final WalletClient walletClient;
  final key = "proton_wallet_k_provider_key";
  List<WalletKey>? walletKeys;

  WalletKeysProvider(this.storage, this.walletClient);

  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>();

  Future<WalletKey?> getWalletKey(String walletID) async {
    var walletKey = _findFromMemory(walletID);
    if (walletKey != null) {
      return walletKey;
    }

    walletKeys = await _getWalletKeys();
    walletKey = _findFromMemory(walletID);
    if (walletKey != null) {
      return walletKey;
    }

    await _fetchFromServer();

    walletKeys = await _getWalletKeys();
    return _findFromMemory(walletID);
  }

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
    final List<ApiWalletData> apiWallets = await walletClient.getWallets();
    final List<WalletKey> tmpKeys = [];
    for (var apiWallet in apiWallets) {
      final key = WalletKey.fromApiWalletKey(apiWallet.walletKey);
      tmpKeys.add(key);
    }
    await saveWalletKeys(tmpKeys);
  }

  /// fetch from local cache
  Future<List<WalletKey>?> _getWalletKeys() async {
    if (walletKeys != null) {
      return walletKeys!;
    }
    final json = await storage.get(key);
    if (json.isEmpty) {
      return null;
    }
    walletKeys = await WalletKey.loadJsonString(json);
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
      // Insert items from list1 first
      for (var key in walletKeys ?? []) {
        mergedMap[key.walletId] = key;
      }
    }

    for (var key in keys) {
      mergedMap[key.walletId] = key;
    }

    walletKeys = mergedMap.values.toList();
    final jsonString = WalletKey.toJsonString(keys);
    await storage.set(key, jsonString);
  }

  Future<void> saveApiWalletKeys(List<ApiWalletKey> items) async {
    final keys = WalletKey.fromApiWalletKeys(items);
    saveWalletKeys(keys);
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}

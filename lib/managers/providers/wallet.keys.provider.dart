import 'dart:async';

import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/models/wallet.key.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/proton_api/wallet.dart';

class WalletKeysProvider implements DataProvider {
  final SecureStorageManager storage;
  final WalletClient walletClient;
  final key = "proton_wallet_k_provider_key";
  List<WalletKey>? walletKeys;

  WalletKeysProvider(this.storage, this.walletClient);

  @override
  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>();

  Future<WalletKey?> getWalletKey(String walletID) async {
    if (walletKeys != null) {
      var key = walletKeys
          ?.where((key) => key.walletId == walletID)
          .toList()
          .firstOrNull;
      return key;
    }

    walletKeys = await _getWalletKeys();
    if (walletKeys != null) {
      var key = walletKeys
          ?.where((key) => key.walletId == walletID)
          .toList()
          .firstOrNull;
      return key;
    }

    // fetch from server
    List<ApiWalletData> apiWallets = await walletClient.getWallets();
    List<WalletKey> tmpKeys = [];
    for (var apiWallet in apiWallets) {
      var key = WalletKey.fromApiWalletKey(apiWallet.walletKey);
      tmpKeys.add(key);
    }
    await saveWalletKeys(tmpKeys);

    walletKeys = await _getWalletKeys();
    if (walletKeys != null) {
      var key = walletKeys
          ?.where((key) => key.walletId == walletID)
          .toList()
          .firstOrNull;
      return key;
    }
    return null;
  }

  Future<List<WalletKey>?> _getWalletKeys() async {
    if (walletKeys != null) {
      return walletKeys!;
    }
    var json = await storage.get(key);
    if (json.isEmpty) {
      return null;
    }
    walletKeys = await WalletKey.loadJsonString(json);
    if (walletKeys != null) {
      return walletKeys!;
    }
    return null;
  }

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
    var jsonString = WalletKey.toJsonString(keys);
    await storage.set(key, jsonString);
  }

  Future<void> saveApiWalletKeys(List<ApiWalletKey> items) async {
    var keys = WalletKey.fromApiWalletKeys(items);
    saveWalletKeys(keys);
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}

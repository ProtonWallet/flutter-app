import 'dart:async';

import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/models/wallet.passphrase.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';

class WalletPassphraseProvider extends DataProvider {
  final SecureStorageManager storage;

  List<WalletPassphrase>? walletPassphrases;

  WalletPassphraseProvider(this.storage);

  StreamController<DataUpdated> dataUpdateController =
      StreamController<DataUpdated>();

  Future<String?> getPassphrase(String walletID) async {
    var passphrases = await _getWalletPassphrases();
    var pwd = passphrases
        .where((passphrase) => passphrase.walletID == walletID)
        .toList()
        .firstOrNull;
    return pwd?.passphrase;
  }

  Future<List<WalletPassphrase>> _getWalletPassphrases() async {
    if (walletPassphrases != null) {
      return walletPassphrases!;
    }

    /// TODO:: move to SecureStorageManager with object
    var json = await storage.get("proton_wallet_p_provider_key");
    if (json.isNotEmpty) {
      walletPassphrases = await WalletPassphrase.loadJsonString(json);
      if (walletPassphrases != null) {
        return walletPassphrases!;
      }
    }
    return [];
  }

  @override
  Future<void> clear() async {
    dataUpdateController.close();
  }
}

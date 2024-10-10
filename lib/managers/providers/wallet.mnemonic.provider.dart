import 'dart:typed_data';

import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/helper/extension/data.dart';
import 'package:wallet/helper/extension/strings.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';

class WalletMnemonicProvider extends DataProvider {
  final WalletKeysProvider walletKeysProvider;
  final WalletsDataProvider walletDataProvider;
  final UserManager userManager;

  WalletMnemonicProvider(
    this.walletKeysProvider,
    this.walletDataProvider,
    this.userManager,
  );

  Future<String> getMnemonicWithID(String walletID) async {
    final secretKey = await walletKeysProvider.getWalletSecretKey(walletID);
    final encryptedMnemonic = await walletDataProvider.getWalletMnemonic(
      walletID,
    );
    if (encryptedMnemonic == null) {
      throw Exception("Wallet encrypted mnemonic not found");
    }

    String encryptedMnemonicString = encryptedMnemonic.mnemonic;
    final walletData =
        await walletDataProvider.getWalletByServerWalletID(walletID);
    if (walletData?.wallet.legacy == 1) {
      /// backward compatibility with old encryption scheme
      final userKeys = await userManager.getUserKeys();
      final binaryEncryptedString = encryptedMnemonic.mnemonic;
      final binaryEncrypted = binaryEncryptedString.base64decode();
      for (final uKey in userKeys) {
        try {
          final Uint8List bytes = proton_crypto.decryptBinary(
            uKey.privateKey,
            uKey.passphrase,
            binaryEncrypted,
          );
          encryptedMnemonicString = bytes.base64encode();
          break;
        } catch (e, stacktrace) {
          logger.i(
            "getMnemonicWithID() error: $e stacktrace: $stacktrace",
          );
          throw Exception("Cannot decrypt with old encryption scheme");
        }
      }
    }
    final String mnemonic = await WalletKeyHelper.decrypt(
      secretKey,
      encryptedMnemonicString,
    );
    return mnemonic;
  }

  @override
  Future<void> clear() async {}

  @override
  Future<void> reload() async {}
}

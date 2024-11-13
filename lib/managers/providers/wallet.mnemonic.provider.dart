import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/rust/api/crypto/wallet_key_helper.dart';
import 'package:wallet/rust/api/proton_wallet/features/transition_layer.dart';

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
    final unlockedWalletKey = await walletKeysProvider.getWalletSecretKey(
      walletID,
    );
    final encryptedMnemonic = await walletDataProvider.getWalletMnemonic(
      walletID,
    );
    if (encryptedMnemonic == null) {
      throw Exception("Wallet encrypted mnemonic not found");
    }

    String encryptedMnemonicString = encryptedMnemonic.mnemonic;
    final walletData = await walletDataProvider.getWalletByServerWalletID(
      walletID,
    );
    if (walletData?.wallet.legacy == 1) {
      /// backward compatibility with old encryption scheme
      final userKeys = await userManager.getUserKeysForTL();
      final userKeyPassphrase = userManager.getUserKeyPassphrase();
      try {
        encryptedMnemonicString = FrbTransitionLayer.decryptWalletKeyLegacy(
          encryptedMnemonicText: encryptedMnemonic.mnemonic,
          userKeys: userKeys,
          userKeyPassword: userKeyPassphrase,
        );
      } catch (e, stacktrace) {
        logger.i(
          "Cannot decrypt with old encryption scheme, try new encryption scheme. Detail error: $e stacktrace: $stacktrace",
        );
        encryptedMnemonicString = encryptedMnemonic.mnemonic;
      }
    }
    final mnemonic = FrbWalletKeyHelper.decrypt(
      base64SecureKey: unlockedWalletKey.toBase64(),
      encryptText: encryptedMnemonicString,
    );
    return mnemonic;
  }

  @override
  Future<void> clear() async {}

  @override
  Future<void> reload() async {}
}

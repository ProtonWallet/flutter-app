import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';

class WalletMnemonicProvider extends DataProvider {
  final WalletKeysProvider walletKeysProvider;
  final WalletsDataProvider walletDataProvider;
  WalletMnemonicProvider(
    this.walletKeysProvider,
    this.walletDataProvider,
  );

  Future<String> getMnemonicWithID(String walletID) async {
    final secretKey = await walletKeysProvider.getWalletSecretKey(walletID);
    final encryptedMnemonic = await walletDataProvider.getWalletMnemonic(
      walletID,
    );
    if (encryptedMnemonic == null) {
      throw Exception("Wallet encrypted mnemonic not found");
    }
    final String mnemonic = await WalletKeyHelper.decrypt(
      secretKey,
      encryptedMnemonic.mnemonic,
    );
    return mnemonic;
  }

  @override
  Future<void> clear() async {}

  @override
  Future<void> reload() async {}
}

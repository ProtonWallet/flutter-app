import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.passphrase.provider.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/rust/api/api_service/proton_api_service.dart';

class DataProviderManager extends Manager {
  final SecureStorageManager storage;
  final ProtonApiService apiService;

  late UserDataProvider userDataProvider;
  late WalletsDataProvider walletDataProvider;
  late WalletPassphraseProvider walletPassphraseProvider;
  late WalletKeysProvider walletKeysProvider;

  DataProviderManager(this.storage, this.apiService) {
    walletPassphraseProvider = WalletPassphraseProvider(storage);
    walletDataProvider = WalletsDataProvider(
      DBHelper.walletDao!,
      DBHelper.accountDao!,
      DBHelper.addressDao!,
      apiService.getWalletClient(),
    );
    walletKeysProvider = WalletKeysProvider(
      storage,
      apiService.getWalletClient(),
    );
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {}
}

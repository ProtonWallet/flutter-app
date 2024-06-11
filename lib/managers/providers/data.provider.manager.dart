import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/providers/contacts.data.provider.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/managers/providers/user.settings.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.keys.provider.dart';
import 'package:wallet/managers/providers/wallet.passphrase.provider.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/drift/wallet.user.settings.queries.dart';
import 'package:wallet/rust/api/api_service/proton_api_service.dart';
// db
import 'package:wallet/models/drift/db/app.database.dart';

abstract class DataProvider {
  Future<void> clear();
}

class DataProviderManager extends Manager {
  final SecureStorageManager storage;
  final ProtonApiService apiService;
  final AppDatabase dbConnection;

  late UserDataProvider userDataProvider;
  late WalletsDataProvider walletDataProvider;
  late WalletPassphraseProvider walletPassphraseProvider;
  late WalletKeysProvider walletKeysProvider;
  late ContactsDataProvider contactsDataProvider;
  late UserSettingsDataProvider userSettingsDataProvider;

  DataProviderManager(this.storage, this.apiService, this.dbConnection);

  @override
  Future<void> login(String userID) async {
    userDataProvider = UserDataProvider(appDatabase: dbConnection);
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
    contactsDataProvider = ContactsDataProvider(
      apiService.getProtonContactsClient(),
      DBHelper.contactsDao!,
    );
    userSettingsDataProvider = UserSettingsDataProvider(
      userID,
      WalletUserSettingsQueries(dbConnection),
      apiService.getSettingsClient(),
    );

    // TODO:: fix this
    WalletManager.walletKeysProvider = walletKeysProvider;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {
    await userSettingsDataProvider.clear();
    await userDataProvider.clear();
    await walletDataProvider.clear();
    await walletPassphraseProvider.clear();
    await walletKeysProvider.clear();
    await contactsDataProvider.clear();
  }
}

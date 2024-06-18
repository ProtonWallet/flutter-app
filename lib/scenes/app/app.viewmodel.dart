import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:wallet/helper/firebase_messaging_helper.dart';
import 'package:wallet/helper/local_auth.dart';
import 'package:wallet/helper/local_notification.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/manager.factory.dart';
import 'package:wallet/managers/preferences/hive.preference.impl.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/scenes/app/app.coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/managers/channels/platform.channel.manager.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/managers/secure.storage/secure.storage.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';

abstract class AppViewModel extends ViewModel<AppCoordinator> {
  AppViewModel(super.coordinator);
}

class AppViewModelImpl extends AppViewModel {
  final ManagerFactory serviceManager;

  AppViewModelImpl(super.coordinator, this.serviceManager);
  final datasourceChangedStreamController =
      StreamController<AppViewModel>.broadcast();

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    /// read env
    final AppConfig config = appConfig;
    final apiEnv = config.apiEnv;

    /// setup local services
    LocalNotification.init();
    FirebaseMessagingHelper.init();
    LocalAuth.init();

    /// platform channel manager
    var platform = PlatformChannelManager(config.apiEnv);
    await platform.init();
    serviceManager.register(platform);

    /// notify native initalized
    platform.initalNativeApiEnv(apiEnv);

    /// inital hive
    await Hive.initFlutter();

    /// persistent storage
    var storage = SecureStorageManager(storage: SecureStorage());
    serviceManager.register(storage);

    /// preferences
    var hiveImpl = HivePreferenceImpl();
    await hiveImpl.init();
    var shared = PreferencesManager(hiveImpl);
    serviceManager.register(shared);

    /// sqlite db
    await DBHelper.init();

    // TODO:: temp move to a cache managerment
    shared.checkif("app_database_force_version", 2, () async {
      await rebuildDatabase();
    });
    AppDatabase dbConnection = AppDatabase(shared);

    /// networking
    var apiServiceManager = ProtonApiServiceManager(apiEnv, storage: storage);
    await apiServiceManager.init();
    serviceManager.register(apiServiceManager);

    /// user manager
    var userManager = UserManager(storage, shared, apiEnv, apiServiceManager);
    serviceManager.register(userManager);

    /// data provider manager
    var dataProviderManager = DataProviderManager(
      storage,
      apiServiceManager.getApiService(),
      dbConnection,
    );
    // dataProviderManager.init();
    serviceManager.register(dataProviderManager);

    /// proton wallet manager
    var protonWallet = ProtonWalletManager();
    serviceManager.register(protonWallet);

    // TODO:: fix me
    WalletManager.userManager = userManager;
    WalletManager.protonWallet = protonWallet;

    /// event loop
    serviceManager.register(EventLoop(protonWallet, userManager, dataProviderManager));

    if (await userManager.sessionExists()) {
      await userManager.tryRestoreUserInfo();
      var userInfo = userManager.userInfo;
      await dataProviderManager.login(userInfo.userId);
      coordinator.showHome(apiEnv);
    } else {
      coordinator.showWelcome(apiEnv);
    }
  }

  @override
  Future<void> move(NavID to) async {}
}

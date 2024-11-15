import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/path.helper.dart';
import 'package:wallet/helper/user.agent.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.migration.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/channels/platform.channel.manager.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/managers/local.auth.manager.dart';
import 'package:wallet/managers/manager.factory.dart';
import 'package:wallet/managers/preferences/hive.preference.impl.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/proton.wallet.manager.dart';
import 'package:wallet/managers/providers/connectivity.provider.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/secure.storage/secure.storage.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/scenes/app/app.coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class AppViewModel extends ViewModel<AppCoordinator> {
  AppViewModel(super.coordinator);
}

class AppViewModelImpl extends AppViewModel {
  final ManagerFactory serviceManager;

  AppViewModelImpl(super.coordinator, this.serviceManager);

  @override
  Future<void> loadData() async {
    /// read env
    final AppConfig config = appConfig;
    final apiEnv = config.apiEnv;

    /// setup local services
    // LocalNotification.init();

    /// local auth manager
    final localAuth = LocalAuthManager();
    await localAuth.init();
    serviceManager.register(localAuth);

    /// platform channel manager
    final platform = PlatformChannelManager(config.apiEnv);
    await platform.init();
    serviceManager.register(platform);

    final userAgent = UserAgent();

    /// notify native initalized
    platform.initalNativeApiEnv(
      apiEnv,
      await userAgent.appVersion,
      await userAgent.ua,
    );

    /// inital hive
    await Hive.initFlutter();

    /// persistent storage
    final storage = SecureStorageManager(storage: SecureStorage());
    serviceManager.register(storage);

    /// preferences
    final hiveImpl = HivePreferenceImpl();
    await hiveImpl.init();
    final shared = PreferencesManager(hiveImpl);
    serviceManager.register(shared);

    /// sqlite db
    await DBHelper.init();

    /// cache manager
    final appMigrationManager = AppMigrationManager(shared);
    await appMigrationManager.init();
    serviceManager.register(appMigrationManager);

    /// db connection
    final AppDatabase dbConnection = AppDatabase(shared);

    /// networking
    final apiServiceManager = ProtonApiServiceManager(apiEnv, storage: storage);
    await apiServiceManager.init();
    serviceManager.register(apiServiceManager);

    /// app state manager
    final appStateManger = AppStateManager(storage, shared);
    await appStateManger.init();
    serviceManager.register(appStateManger);

    /// user manager
    final userManager = UserManager(
      storage,
      shared,
      apiEnv,
      apiServiceManager,
      dbConnection,
    );
    serviceManager.register(userManager);

    /// data provider manager
    final dataProviderManager = DataProviderManager(
      apiEnv,
      storage,
      shared,
      apiServiceManager,
      dbConnection,
      userManager,
    );
    // dataProviderManager.init();
    serviceManager.register(dataProviderManager);

    final walletManager = WalletManager(
      userManager,
      dataProviderManager,
    );
    // walletManager.init();
    serviceManager.register(walletManager);

    // TODO(fix): this is bad.
    dataProviderManager.walletManager = walletManager;

    final dbPath = await getDatabaseFolderPath();

    /// new rust proton wallet manager
    final protonWalletManager = ProtonWalletManager(
      apiServiceManager,
      storage,
      userManager,
      dbPath,
    );
    serviceManager.register(protonWalletManager);

    /// event loop
    serviceManager.register(EventLoop(
      userManager,
      walletManager,
      dataProviderManager,
      appStateManger,
      ConnectivityProvider(),
      shared,
      apiServiceManager,
      duration: const Duration(seconds: 30),
    ));

    if (await userManager.sessionExists()) {
      await userManager.tryRestoreUserInfo();
      final userInfo = userManager.userInfo;
      await serviceManager.login(userInfo.userId);
      coordinator.showHome(apiEnv);
    } else {
      coordinator.showWelcome(apiEnv);
    }
  }

  @override
  Future<void> move(NavID to) async {}
}

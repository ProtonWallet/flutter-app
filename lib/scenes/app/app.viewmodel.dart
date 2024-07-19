import 'dart:async';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/local_notification.dart';
import 'package:wallet/helper/user.agent.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/channels/platform.channel.manager.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/managers/local.auth.manager.dart';
import 'package:wallet/managers/manager.factory.dart';
import 'package:wallet/managers/preferences/hive.preference.impl.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/secure.storage/secure.storage.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
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
    LocalNotification.init();

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

    // TODO(fix): temp move to a cache managerment
    shared.checkif("app_database_force_version", 2, () async {
      await rebuildDatabase();
    });
    final AppDatabase dbConnection = AppDatabase(shared);

    /// networking
    final apiServiceManager = ProtonApiServiceManager(apiEnv, storage: storage);
    await apiServiceManager.init();
    serviceManager.register(apiServiceManager);

    /// app state manager
    final appStateManger = AppStateManager(storage);
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
      apiServiceManager.getApiService(),
      dbConnection,
      userManager,
    );
    // dataProviderManager.init();
    serviceManager.register(dataProviderManager);

    /// proton wallet manager
    final protonWallet = ProtonWalletManager();
    serviceManager.register(protonWallet);

    // TODO(fix): fix me
    WalletManager.userManager = userManager;
    WalletManager.protonWallet = protonWallet;

    /// event loop
    serviceManager.register(EventLoop(
      protonWallet,
      userManager,
      dataProviderManager,
      appStateManger,
    ));

    if (await userManager.sessionExists()) {
      await userManager.tryRestoreUserInfo();
      final userInfo = userManager.userInfo;
      await dataProviderManager.login(userInfo.userId);
      await userManager.login(userInfo.userId);
      coordinator.showHome(apiEnv);
    } else {
      coordinator.showWelcome(apiEnv);
    }
  }

  @override
  Future<void> move(NavID to) async {}
}

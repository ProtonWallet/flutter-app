import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/constants/app.config.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/managers/channels/platform.channel.manager.dart';
import 'package:wallet/managers/event.loop.manager.dart';
import 'package:wallet/managers/secure.storage/secure.storage.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/user.manager.dart';
import 'package:wallet/managers/wallet/proton.wallet.manager.dart';
import 'package:wallet/managers/wallet/wallet.manager.dart';
import 'package:wallet/rust/api/api_service/proton_api_service.dart';
import 'package:wallet/scenes/app/app.view.dart';
import 'package:wallet/scenes/app/app.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';

late ProtonApiService protonApiService; //temp. will need to move to manager

class AppCoordinator extends Coordinator {
  late ViewBase widget;

  AppCoordinator();

  Future<void> init() async {
    // persistent storage
    var storage = SecureStorageManager(storage: SecureStorage());
    serviceManager.register(storage);

    // shared preferences
    var shared = await SharedPreferences.getInstance();
    // sqlite db
    await DBHelper.init(); // Move to the place after view is created

    var apiEnv = appConfig.apiEnv;
    // user manager
    var userManager = UserManager(storage, shared, apiEnv);
    serviceManager.register(userManager);

    // proton wallet manager
    var protonWallet = ProtonWalletManager(storage: storage);
    serviceManager.register(protonWallet);

    // TODO:: fix me
    WalletManager.apiEnv = apiEnv;
    WalletManager.userManager = userManager;
    WalletManager.protonWallet = protonWallet;

    // event loop
    serviceManager.register(EventLoop(protonWallet, userManager));

    // platform channel manager
    var platform = PlatformChannelManager();
    platform.init();
    serviceManager.register(platform);
  }

  @override
  void end() {}

  @override
  Widget start() {
    final nativeViewChannel = serviceManager.get<PlatformChannelManager>();
    ViewBase view =
        WelcomeCoordinator(nativeViewChannel: nativeViewChannel).start();
    var viewModel = AppViewModelImpl(
      this,
    );
    widget = AppView(
      viewModel,
      view,
    );
    return widget;
  }
}

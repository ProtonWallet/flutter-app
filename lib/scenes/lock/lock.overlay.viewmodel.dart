import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/local.auth.manager.dart';
import 'package:wallet/models/unlock.type.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/lock/lock.overlay.coordinator.dart';

enum UnlockState {
  locked,

  unlocked,
}

abstract class LockViewModel extends ViewModel<LockCoordinator> {
  LockViewModel(super.coordinator);

  bool isLocked = false;
  String error = "";
  Future<void> unlock();
  Future<void> logout();
}

class LockViewModelImpl extends LockViewModel with WidgetsBindingObserver {
  final AppStateManager appStateManager;
  final LocalAuthManager localAuthManager;

  LockViewModelImpl(
    super.coordinator,
    this.appStateManager,
    this.localAuthManager,
  );

  final datasourceChangedStreamController =
      StreamController<LockViewModel>.broadcast();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    WidgetsBinding.instance.addObserver(this);
    final type = await appStateManager.getUnlockType();
    isLocked = type.type == UnlockType.biometrics;
    // check last lock timmer
    datasourceChangedStreamController.add(this);
    if (isLocked) {
      await unlock();
    }
  }

  @override
  Future<void> unlock() async {
    final count = await appStateManager.getErrorCount();
    if (count.count != 0) {
      error = "You will be locked out after ${5 - count.count} failed attempts";
    } else {
      error = "";
    }
    final result = await localAuthManager.authenticate("Unlock Proton Wallet");
    if (result) {
      isLocked = false;
      error = "";
      await appStateManager.updateCount(UnlockErrorCount.zero());
    } else {
      isLocked = true;
      await appStateManager.updateCount(count.plus());
    }
    datasourceChangedStreamController.add(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      default:
        break;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        logger.i("App is in foreground");
        if (isLocked) {
          // lock the app
          isLocked = true;
          datasourceChangedStreamController.add(this);

          unlock();
        }
      // App comes to foreground
      case AppLifecycleState.inactive:
        logger.i("App is inactive");
      // App is inactive
      case AppLifecycleState.paused:
        logger.i("App is in background");
        if (!isLocked) {
          // lock the app
          isLocked = true;
          datasourceChangedStreamController.add(this);
        }
      // App goes to background
      case AppLifecycleState.detached:
        logger.i("App is detached");
      // App is detached
      case AppLifecycleState.hidden:
        logger.i("App is hidden");
    }
  }

  @override
  Future<void> logout() async {}
}

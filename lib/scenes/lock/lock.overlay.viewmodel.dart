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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> loadData() async {
    WidgetsBinding.instance.addObserver(this);
    final type = await appStateManager.getUnlockType();
    isLocked = type.type == UnlockType.biometrics;
    // check last lock timmer
    sinkAddSafe();
    if (isLocked) {
      await unlock();
    }
  }

  @override
  Future<void> unlock() async {
    final type = await appStateManager.getUnlockType();
    if (type.type == UnlockType.none) {
      // lock the app
      isLocked = false;
      sinkAddSafe();

      return;
    }
    // lock the app
    isLocked = true;
    sinkAddSafe();

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
    sinkAddSafe();
  }

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
        logger.d("App is in foreground");
        if (isLocked) {
          unlock();
        }
      // App comes to foreground
      case AppLifecycleState.inactive:
        logger.d("App is inactive");
      // App is inactive
      case AppLifecycleState.paused:
        logger.d("App is in background");
      // App goes to background
      case AppLifecycleState.detached:
        logger.d("App is detached");
      // App is detached
      case AppLifecycleState.hidden:
        logger.d("App is hidden");
    }
  }

  @override
  Future<void> logout() async {}
}

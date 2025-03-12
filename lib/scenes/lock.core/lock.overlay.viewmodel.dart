import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/models/unlock.type.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/lock.core/lock.overlay.coordinator.dart';

abstract class LockCoreViewModel extends ViewModel<LockCoordinator> {
  LockCoreViewModel(super.coordinator);

  bool initialized = false;
}

class LockCoreViewModelImpl extends LockCoreViewModel
    with WidgetsBindingObserver {
  final AppStateManager appStateManager;

  LockCoreViewModelImpl(
    super.coordinator,
    this.appStateManager,
  );

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> loadData() async {
    WidgetsBinding.instance.addObserver(this);
    bool needUnlock = false;
    final type = await appStateManager.getUnlockType();
    switch (type.type) {
      case UnlockType.biometrics:
        needUnlock = true;
      case UnlockType.none:
        needUnlock = false;
    }

    /// check last lock timer
    final isLockTimerNeedUnlock = await appStateManager.isLockTimerNeedUnlock();
    if (!appStateManager.isLocked && needUnlock && isLockTimerNeedUnlock) {
      /// only lock when user is not authenticating
      if (!appStateManager.isAuthenticating) {
        appStateManager.isLocked = true;
        await coordinator.showLockOverlay(askUnlockWhenOnload: true);
      }
    }

    /// mark initialized = true, to hide lockCore view from homepage
    initialized = true;
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
        appStateManager.isInBackground = false;
      case AppLifecycleState.inactive:
        logger.d("App is inactive");
        appStateManager.isInBackground = true;
        if (!appStateManager.isLocked) {
          /// update app last activate time only when app is unlocked
          appStateManager.saveAppLastActivateTime();

          /// only lock when user is not authenticating
          if (!appStateManager.isAuthenticating) {
            appStateManager.isLocked = true;
            coordinator.showLockOverlay(askUnlockWhenOnload: false);
          }
        }
      case AppLifecycleState.paused:
        logger.d("App is in background");
      case AppLifecycleState.detached:
        logger.d("App is detached");
      case AppLifecycleState.hidden:
        logger.d("App is hidden");
    }
  }
}

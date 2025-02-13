import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/local.auth.manager.dart';
import 'package:wallet/models/unlock.type.dart';
import 'package:wallet/scenes/core/coordinator.dart';
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
  bool isLockTimerNeedUnlock = false;
  String error = "";

  Future<void> unlock();

  Future<void> logout();
}

class LockViewModelImpl extends LockViewModel with WidgetsBindingObserver {
  final AppStateManager appStateManager;
  final LocalAuthManager localAuthManager;

  /// Used to prevent the biometric unlock from being called
  /// multiple times when the app is resumed
  bool lastUnlockFailed = false;

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

    sinkAddSafe();
    if (isLocked) {
      await unlock();
    }
  }

  @override
  Future<void> unlock() async {
    final type = await appStateManager.getUnlockType();
    switch (type.type) {
      case UnlockType.biometrics:
        // lock the app
        isLocked = true;
      case UnlockType.none:
        isLocked = false;
        sinkAddSafe();
        return;
    }

    /// check last lock timer
    isLockTimerNeedUnlock = await appStateManager.isLockTimerNeedUnlock();
    if (!isLockTimerNeedUnlock) {
      /// still in lock timer range, we don't need to ask user to unlock
      isLocked = false;
      sinkAddSafe();
      return;
    }
    sinkAddSafe();

    final count = await appStateManager.getErrorCount();
    final result = await localAuthManager.authenticate("Unlock Proton Wallet");
    if (result) {
      isLocked = false;
      error = "";
      lastUnlockFailed = true;
      await appStateManager.updateCount(UnlockErrorCount.zero());
    } else {
      isLocked = true;
      lastUnlockFailed = false;
      final newCount = count.plus();
      await appStateManager.updateCount(newCount);
      error =
          "You will be locked out after ${5 - newCount.count} failed attempts";
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
        if (isLocked && lastUnlockFailed) {
          unlock();
        }
      // App comes to foreground
      case AppLifecycleState.inactive:
        logger.d("App is inactive");
        lockIfNeeded();
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

  Future<void> lockIfNeeded() async {
    final type = await appStateManager.getUnlockType();
    switch (type.type) {
      case UnlockType.biometrics:

        /// update app last activate time only when app is unlocked
        if (!isLocked) {
          await appStateManager.saveAppLastActivateTime();
          isLockTimerNeedUnlock = await appStateManager.isLockTimerNeedUnlock();

          if (isLockTimerNeedUnlock) {
            /// popup to home page so we can show lock overlay correctly
            final BuildContext? context =
                Coordinator.rootNavigatorKey.currentContext;
            if (context != null && context.mounted) {
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          }
        }

        /// lock the app
        isLocked = true;
      case UnlockType.none:
        isLocked = false;
    }
    sinkAddSafe();
  }
}

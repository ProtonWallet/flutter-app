import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/local.auth.manager.dart';
import 'package:wallet/models/unlock.type.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/lock.overlay/lock.overlay.coordinator.dart';

enum UnlockState {
  locked,
  unlocked,
}

abstract class LockOverlayViewModel extends ViewModel<LockOverlayCoordinator> {
  LockOverlayViewModel(super.coordinator);

  bool isLockTimerNeedUnlock = false;
  bool needUnlock = true;
  String error = "";

  Future<void> unlock();

  Future<void> logout();
}

class LockOverlayViewModelImpl extends LockOverlayViewModel
    with WidgetsBindingObserver {
  final AppStateManager appStateManager;
  final LocalAuthManager localAuthManager;

  /// Used to prevent the biometric unlock from being called
  /// multiple times when the app is resumed
  bool lastUnlockFailed = true;
  bool isUnlocking = false;
  bool isLocked = false;
  bool hadLogout = false;
  bool askUnlockWhenOnload = false;

  LockOverlayViewModelImpl(
      super.coordinator, this.appStateManager, this.localAuthManager,
      {required this.askUnlockWhenOnload});

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> loadData() async {
    WidgetsBinding.instance.addObserver(this);
    if (askUnlockWhenOnload) {
      unlock();
    }

    /// check last lock timer
    isLockTimerNeedUnlock = await appStateManager.isLockTimerNeedUnlock();

    /// we don't need to ask user unlock if UnlockType is none
    final type = await appStateManager.getUnlockType();
    if (type.type == UnlockType.none) {
      needUnlock = false;
    }
    sinkAddSafe();
  }

  @override
  Future<void> unlock() async {
    isUnlocking = true;
    final type = await appStateManager.getUnlockType();
    switch (type.type) {
      case UnlockType.biometrics:
        // lock the app
        isLocked = true;
      case UnlockType.none:

        /// wait 0.25s to make UI transform more smoothly
        await Future.delayed(const Duration(milliseconds: 250));
        unlockSuccess();
        return;
    }

    /// check last lock timer
    isLockTimerNeedUnlock = await appStateManager.isLockTimerNeedUnlock();
    if (!isLockTimerNeedUnlock) {
      /// still in lock timer range, we don't need to ask user to unlock
      /// wait 0.25s to make UI transform more smoothly
      await Future.delayed(const Duration(milliseconds: 250));
      unlockSuccess();
      return;
    }
    sinkAddSafe();

    final count = await appStateManager.getErrorCount();
    appStateManager.isAuthenticating = true;
    final result = await localAuthManager.authenticate("Unlock Proton Wallet");
    appStateManager.isAuthenticating = false;
    if (result) {
      await appStateManager.updateCount(UnlockErrorCount.zero());
      unlockSuccess();
      return;
    } else {
      lastUnlockFailed = false;
      final newCount = count.plus();
      await appStateManager.updateCount(newCount);
      error =
          "You will be locked out after ${5 - newCount.count} failed attempts";
    }
    isUnlocking = false;
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
        if (lastUnlockFailed && !isUnlocking) {
          unlock();
        }
        sinkAddSafe();
      case AppLifecycleState.inactive:
        logger.d("App is inactive");
      case AppLifecycleState.paused:
        logger.d("App is in background");
      case AppLifecycleState.detached:
        logger.d("App is detached");
      case AppLifecycleState.hidden:
        logger.d("App is hidden");
    }
  }

  @override
  Future<void> logout() async {
    if (!hadLogout) {
      hadLogout = true;
      appStateManager.logoutFromLock();
    }
  }

  void unlockSuccess() {
    appStateManager.isLocked = false;

    /// pop this lock overlay
    final BuildContext? context = Coordinator.rootNavigatorKey.currentContext;
    if (context != null && context.mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
}

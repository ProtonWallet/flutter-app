import 'dart:async';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/local.auth.manager.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/models/unlock.timer.dart';
import 'package:wallet/models/unlock.type.dart';
import 'package:wallet/rust/api/api_service/proton_users_client.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/security.setting/security.setting.coordinator.dart';

abstract class SecuritySettingViewModel
    extends ViewModel<SecuritySettingCoordinator> {
  SecuritySettingViewModel(super.coordinator);

  UnlockType selectedType = UnlockType.none;
  LockTimer lockTimer = LockTimer.immediately;

  Future<String> updateType(UnlockType newType);

  Future<void> updateLockTimer(LockTimer newTimer);

  bool isLoading = true;

  /// This is only for TOTP (authenticator app), not for security key (FIDO2)
  bool hadSetup2FATotp = false;

  bool hadSetup2FASecurityKey = false;

  String error = "";
}

class SecuritySettingViewModelImpl extends SecuritySettingViewModel {
  SecuritySettingViewModelImpl(
    super.coordinator,
    this.appStateManager,
    this.localAuthManager,
    this.protonUserApi,
    this.userDataProvider,
  );

  ///
  final AppStateManager appStateManager;
  final LocalAuthManager localAuthManager;

  final ProtonUsersClient protonUserApi;
  final UserDataProvider userDataProvider;

  StreamSubscription? protonUserDataSubscription;

  @override
  void dispose() {
    protonUserDataSubscription?.cancel();
    super.dispose();
  }

  @override
  Future<void> loadData() async {
    protonUserDataSubscription = userDataProvider.stream.listen((state) async {
      if (state is TwoFaUpdated) {
        await _check2FAStatus();
      }
    });

    final unlock = await appStateManager.getUnlockType();
    selectedType = unlock.type;

    lockTimer = await appStateManager.getLockTimer();

    isLoading = true;

    sinkAddSafe();

    await _check2FAStatus();
  }

  Future<void> _check2FAStatus() async {
    try {
      final protonUserSettings = await protonUserApi.getUserSettings();
      if (protonUserSettings.twoFa != null) {
        /// 0 for disabled, 1 for TOTP (authenticator app), 2 for security key (FIDO2), 3 for both
        hadSetup2FATotp =
            protonUserSettings.twoFa!.enabled != 0 &&
            protonUserSettings.twoFa!.enabled != 2;

        hadSetup2FASecurityKey =
            protonUserSettings.twoFa!.enabled != 0 &&
            protonUserSettings.twoFa!.enabled != 1;
      }
      isLoading = false;
    } on BridgeError catch (e) {
      appStateManager.updateStateFrom(e);
      error = e.localizedString;
    } catch (e) {
      error = e.toString();
    }
    sinkAddSafe();
  }

  @override
  Future<String> updateType(UnlockType newType) async {
    final newValue = newType;

    final currentType = await appStateManager.getUnlockType();
    if (currentType.type != newValue) {
      appStateManager.isAuthenticating = true;
      final authenticated = await localAuthManager.authenticate(
        "Changing unlock type",
      );
      appStateManager.isAuthenticating = false;
      if (authenticated) {
        selectedType = newValue;
        await appStateManager.saveUnlockType(UnlockModel(type: newValue));
        sinkAddSafe();
      } else {
        if (!localAuthManager.canCheckBiometrics) {
          return "Please enable FaceID in system settings";
        }
      }
    }
    return "";
  }

  @override
  Future<void> move(NavID to) async {
    switch (to) {
      case NavID.twoFactorAuthSetup:
        coordinator.showTwoFactorAuthSetup();
      case NavID.twoFactorAuthDisable:
        coordinator.showTwoFactorAuthDisable();
      default:
        break;
    }
  }

  @override
  Future<void> updateLockTimer(LockTimer newTimer) async {
    lockTimer = newTimer;
    await appStateManager.saveLockTimer(newTimer);
    sinkAddSafe();
  }
}

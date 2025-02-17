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
  bool hadSetup2FA = false;
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
    protonUserDataSubscription = userDataProvider.stream.listen((state) {
      if (state is TwoFaUpdated) {
        hadSetup2FA = state.updatedData;
        sinkAddSafe();
      }
    });

    final unlock = await appStateManager.getUnlockType();
    selectedType = unlock.type;

    lockTimer = await appStateManager.getLockTimer();

    isLoading = true;

    sinkAddSafe();

    try {
      final protonUserSettings = await protonUserApi.getUserSettings();
      if (protonUserSettings.twoFa != null) {
        hadSetup2FA = protonUserSettings.twoFa!.enabled != 0;
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

//app.state.data.provider.dart

import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/models/unlock.type.dart';
import 'package:wallet/rust/common/errors.dart';

abstract class AppState extends DataState {}

class AppSessionFailed extends AppState {
  final String message;

  AppSessionFailed({required this.message});

  @override
  List<Object?> get props => [message];
}

class AppPermissionState extends AppState {
  final String message;

  AppPermissionState({required this.message});

  @override
  List<Object?> get props => [message];
}

class AppUnlockFailedState extends AppState {
  final String message;

  AppUnlockFailedState({required this.message});

  @override
  List<Object?> get props => [message];
}

// class AppUnlockLogoutState extends AppState {
//   final String message;
//   AppUnlockLogoutState({required this.message});

//   @override
//   List<Object?> get props => [message];
// }

class AppStateManager extends DataProvider implements Manager {
  final bool appInBetaState = true;

  /// const key
  final unlockKey = "proton_wallet_app_k_unlock_type";
  final unlockErrorKey = "proton_wallet_app_k_unlock_error_count";

  /// Secure storage key for the app state
  final SecureStorageManager secureStore;

  /// Shared preferences key for the app state

  /// app level configs

  /// session level configs

  /// constructor
  AppStateManager(this.secureStore);

  Future<void> handleError(BridgeError exception) async {
    final message = parseSessionExpireError(exception);
    if (message != null) {
      emitState(AppSessionFailed(message: message));
      return;
    }
  }

  Future<void> handleWalletListError(BridgeError exception) async {
    final error = parseResponseError(exception);
    if (error != null && error.code == 404 && appInBetaState) {
      emitState(AppPermissionState(message: error.error));
      return;
    }
  }

  Future<UnlockModel> getUnlockType() async {
    final saved = await secureStore.get(unlockKey);
    if (saved.isEmpty) {
      return UnlockModel(type: UnlockType.none);
    }
    return UnlockModel.fromJsonString(saved);
  }

  Future<void> saveUnlockType(UnlockModel model) async {
    final save = model.toString();
    await secureStore.set(unlockKey, save);
  }

  Future<UnlockErrorCount> getErrorCount() async {
    final saved = await secureStore.get(unlockErrorKey);
    if (saved.isEmpty) {
      return UnlockErrorCount(count: 0);
    }
    final count = UnlockErrorCount.fromJsonString(saved);
    return count;
  }

  Future<void> updateCount(UnlockErrorCount count) async {
    final save = count.toString();
    await secureStore.set(unlockErrorKey, save);
    if (count.count >= 5) {
      emitState(AppUnlockFailedState(message: "Unlock failed too many times"));
    }
  }

  void logoutFromLock() {
    // emitState(AppUnlockLogoutState(message: "Logout from lock"));
  }

  @override
  Future<void> clear() async {}

  @override
  Future<void> dispose() {
    // TODO(fix): implement dispose
    throw UnimplementedError();
  }

  @override
  Future<void> login(String userID) {
    // TODO(fix): implement login
    throw UnimplementedError();
  }

  @override
  Future<void> init() async {}
  @override
  Future<void> logout() async {}
}

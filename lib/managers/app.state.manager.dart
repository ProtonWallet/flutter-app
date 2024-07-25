//app.state.data.provider.dart

import 'dart:math';

import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
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

class AppForceUpgradeState extends AppState {
  final String message;

  AppForceUpgradeState({required this.message});

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

  /// none key chain
  final eventloopErrorCountKey = "proton_wallet_app_k_event_loop_error_count";
  final syncErrorCountKey = "proton_wallet_app_k_sync_error_count";

  /// Secure storage key for the app state
  final SecureStorageManager secureStore;

  /// Shared preferences key for the app state
  final PreferencesManager shared;

  /// app level configs

  /// session level configs

  /// constructor
  AppStateManager(this.secureStore, this.shared);

  Future<void> handleError(BridgeError exception) async {
    final message = parseSessionExpireError(exception);
    if (message != null) {
      emitState(AppSessionFailed(message: message));
      return;
    }
  }

  Future<void> handleForceUpgrade(BridgeError exception) async {
    final error = parseResponseError(exception);
    if (error != null && (error.code == 5003 || error.code == 5005)) {
      emitState(AppForceUpgradeState(message: error.error));
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

  Future<int> getSyncErrorCoount() async {
    final count = await shared.read(syncErrorCountKey);
    await shared.write(eventloopErrorCountKey, count + 1);
    return _getNextBackoffDuration(
      count,
      minSeconds: 120,
    );
  }

  Future<void> resetSyncErrorCoount() async {
    await shared.write(syncErrorCountKey, 0);
  }

  ///
  Future<int> getEventloopDuration() async {
    final count = await shared.read(eventloopErrorCountKey);
    await shared.write(eventloopErrorCountKey, count + 1);
    return _getNextBackoffDuration(
      count,
      maxSeconds: 300,
    );
  }

  Future<void> resetEventloopDuration() async {
    await shared.write(eventloopErrorCountKey, 0);
  }

  ///
  Future<int> getSyncDuration() async {
    final count = await shared.read(eventloopErrorCountKey);

    return _getNextBackoffDuration(
      count,
      maxSeconds: 120,
    );
  }

  Future<void> resetSyncDuration() async {
    await shared.write(eventloopErrorCountKey, 0);
  }

  int _getNextBackoffDuration(
    int attempt, {
    int minSeconds = 30,
    int maxSeconds = 600,
  }) {
    // Calculate the exponential backoff duration
    final int exponentialBackoff = pow(2, attempt).toInt();

    // Generate a random value within the exponential backoff range
    final int randomBackoff = Random().nextInt(exponentialBackoff + 1);

    // Ensure the random backoff is within the specified range
    final int duration = min(max(minSeconds, randomBackoff), maxSeconds);

    return duration;
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

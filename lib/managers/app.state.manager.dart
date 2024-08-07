//app.state.data.provider.dart

import 'dart:math';

import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/providers/data.provider.manager.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/models/unlock.type.dart';
import 'package:wallet/rust/common/errors.dart';

enum LoadingTask {
  eligible,
  homeRecheck,
  // subscription,
  // controllers,
  // userSettings,
  // priceGraph,
  // recoveryState,
  // twoFAState,
  // exclusiveInvite,
  // contacts,
  // exchangeRate,

  // discoverContents,
  // emailAddressProvider,
  // eventLoop,
}

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
  bool isHomeInitialed = false;
  bool isHomeLoading = false;
  bool isConnectivityOK = true;
  bool exponentialBackoffForConcurrentlyMode = false;
  List<LoadingTask> failedTask = [];

  /// const key
  final unlockKey = "proton_wallet_app_k_unlock_type";
  final unlockErrorKey = "proton_wallet_app_k_unlock_error_count";

  /// none key chain
  final eventloopErrorCountKey = "proton_wallet_app_k_event_loop_error_count";
  final syncErrorCountKey = "proton_wallet_app_k_sync_error_count";

  /// user eligible
  final userEligible = "proton_wallet_app_k_is_user_eligible";

  /// Secure storage key for the app state
  final SecureStorageManager secureStore;

  /// Shared preferences key for the app state
  final PreferencesManager shared;

  /// app level configs

  /// session level configs

  /// constructor
  AppStateManager(
    this.secureStore,
    this.shared,
  );

  void updateStateFrom(BridgeError exception) {
    handleSessionError(exception);
    handleForceUpgrade(exception);
    handleMuonClientError(exception);
  }

  void handleMuonClientError(BridgeError exception) {
    if (ifMuonClientError(exception)) {
      isConnectivityOK = false;
    }
  }

  void handleSessionError(BridgeError exception) {
    final message = parseSessionExpireError(exception);
    if (message != null) {
      emitState(AppSessionFailed(message: message));
      return;
    }
  }

  void handleForceUpgrade(BridgeError exception) {
    final error = parseResponseError(exception);
    if (error != null && (error.code == 5003 || error.code == 5005)) {
      emitState(AppForceUpgradeState(message: error.error));
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
    final count = await shared.read(eventloopErrorCountKey) ?? 0;
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

  ///
  Future<int> getEligible() async {
    final count = await secureStore.get(userEligible);
    return count == "1" ? 1 : 0;
  }

  /// get backoff duration for concurrent situation when server from offline back to online
  int getExponentialBackoffForConcurrently() {
    if (exponentialBackoffForConcurrentlyMode) {
      return _getNextBackoffDuration(0, minSeconds: 5, maxSeconds: 10);
    }
    return 0;
  }

  Future<void> setEligible() async {
    await secureStore.set(userEligible, "1");
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

  void loadingFailed(LoadingTask task) {
    if (!failedTask.any((element) => element == task)) {
      failedTask.add(task);
    }
  }

  void loadingSuccess(LoadingTask task) {
    failedTask.remove(task);
  }

  @override
  Future<void> clear() async {}

  @override
  Future<void> dispose() {
    throw UnimplementedError();
  }

  @override
  Future<void> login(String userID) async {}

  @override
  Future<void> init() async {}

  @override
  Future<void> logout() async {}
}

//final backoff = ExponentialBackoff(base: 1000, randomInterval: 500);
// Attempt 0: wait for 1100 ms
// Attempt 1: wait for 2300 ms
// Attempt 2: wait for 3950 ms
// Attempt 3: wait for 6800 ms
// Attempt 4: wait for 15800 ms
// Attempt 5: wait for 30800 ms
// Attempt 6: wait for 61900 ms
// Attempt 7: wait for 124700 ms
// Attempt 8: wait for 248200 ms
// Attempt 9: wait for 496900 ms

// this is new one but havne't used yet need more tests
class ExponentialBackoff {
  final int base;
  final int randomInterval;
  final Random _random = Random();

  ExponentialBackoff({required this.base, required this.randomInterval});

  Duration calculateWaitInterval(int n) {
    // Calculate the exponential backoff time
    final int exponentialBackoff = base * pow(2, n).toInt();

    // Generate a random jitter within the range [-randomInterval, randomInterval]
    final int jitter = _random.nextInt(2 * randomInterval + 1) - randomInterval;

    // Calculate the final wait interval
    int waitInterval = exponentialBackoff + jitter;

    // Ensure the wait interval is not negative
    if (waitInterval < 0) {
      waitInterval = 0;
    }

    return Duration(milliseconds: waitInterval);
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/user.agent.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/preferences/preferences.keys.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/users/user.manager.event.dart';
import 'package:wallet/managers/users/user.manager.state.dart';
import 'package:wallet/models/drift/db/app.database.dart';
import 'package:wallet/models/drift/user.keys.queries.dart';
import 'package:wallet/models/drift/users.queries.dart';
import 'package:wallet/models/native.session.model.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/auth_credential.dart';
import 'package:wallet/rust/proton_api/proton_users.dart';

import 'user.key.dart';

class UserManager extends Bloc<UserManagerEvent, UserManagerState>
    implements Manager {
  final SecureStorageManager storage;
  final PreferencesManager shared;
  final AppDatabase dbConnection;
  final ApiEnv apiEnv;

  ///
  late UserInfo userInfo;

  /// api service here
  final ProtonApiServiceManager apiServiceManager;

  /// provider
  late UserDataProvider userDataProvider;

  UserManager(
    this.storage,
    this.shared,
    this.apiEnv,
    this.apiServiceManager,
    this.dbConnection,
  ) : super(UserManagerInitial());

  /// Login and session management
  Future<bool> sessionExists() async {
    await firstRun();
    return await storage.get("sessionId") != "";
  }

  String get userID => userInfo.userId;

  Future<void> firstRun() async {
    await shared.isFirstTimeEntry(() async {
      await storage.deleteAll();
    });
  }

  Future<FlutterSession> getChildSession() async {
    final userAgent = UserAgent();
    final childSession = await proton_api.fork(
      appVersion: await userAgent.appVersion,
      userAgent: await userAgent.ua,
      clientChild: "flutter-wallet-lite",
    );
    return FlutterSession(
        userId: userInfo.userId,
        userName: userInfo.userName,
        sessionId: childSession.sessionId,
        accessToken: childSession.accessToken,
        refreshToken: childSession.refreshToken,
        scopes: childSession.scopes,
        passphrase: "");
  }

  //Flutter login must be call if use flutter login UI
  Future<void> flutterLogin(AuthCredential auth) async {
    userInfo = UserInfo.fromAuth(auth);
    // save
    await trySaveUserInfo();
  }

  // Native login must be call if use native login UI
  Future<void> nativeLogin(UserInfo userInfo) async {
    this.userInfo = userInfo;
    // save
    await trySaveUserInfo();
  }

  //
  Future<void> tryRestoreUserInfo() async {
    userInfo = UserInfo(
        userId: await storage.get("userId"),
        userMail: await storage.get("userMail"),
        userName: await storage.get("userName"),
        userDisplayName: await storage.get("userDisplayName"),
        sessionId: await storage.get("sessionId"),
        accessToken: await storage.get("accessToken"),
        refreshToken: await storage.get("refreshToken"),
        scopes: await storage.get("scopes"),
        userKeyID: await storage.get("userKeyID"),
        userPrivateKey: await storage.get("userPrivateKey"),
        userPassphrase: await storage.get("userPassphrase"));
  }

  Future<void> trySaveUserInfo() async {
    // Notes:: the api service is reading the session in parallel make sure await each other
    await storage.set("userId", userInfo.userId);
    await storage.set("userMail", userInfo.userMail);
    await storage.set("userName", userInfo.userName);
    await storage.set("userDisplayName", userInfo.userDisplayName);
    await storage.set("sessionId", userInfo.sessionId);
    await storage.set("accessToken", userInfo.accessToken);
    await storage.set("refreshToken", userInfo.refreshToken);
    await storage.set("scopes", userInfo.scopes);
    await storage.set("userKeyID", userInfo.userKeyID);
    await storage.set("userPrivateKey", userInfo.userPrivateKey);
    await storage.set("userPassphrase", userInfo.userPassphrase);
  }

  Future<ProtonUserKey> getDefaultKey() async {
    // default key if can't found any keys
    final userKeyID = userInfo.userKeyID;
    final privateKey = userInfo.userPrivateKey;

    return ProtonUserKey(
      id: userKeyID,
      version: 4,
      privateKey: privateKey,
      primary: 1,
      active: 1,
      fingerprint: '',
    );
  }

  Future<ProtonUserKey> getPrimaryKeyForTL() async {
    final userKeyID = userInfo.userKeyID;
    final privateKey = userInfo.userPrivateKey;
    final keys = await getUserKeysForTL();
    final found = keys.where((item) => item.primary == 1);
    if (found.isNotEmpty) {
      final key = found.first;
      return key;
    }
    if (userKeyID == "" || privateKey == "") {
      throw Exception(
          "First key is null, cannot decrypt wallet key. relogin or debug.");
    }
    return ProtonUserKey(
      id: userKeyID,
      privateKey: privateKey,
      version: 4,
      fingerprint: '',
      primary: 1,
      active: 1,
    );
  }

  Future<UserKey> getPrimaryKey() async {
    // default key if can't found any keys
    final userKeyID = userInfo.userKeyID;
    final privateKey = userInfo.userPrivateKey;
    final passphrase = userInfo.userPassphrase;
    final userID = userInfo.userId;
    final keys = await userDataProvider.getUserKeys(userID);

    final found = keys.where((item) => item.primary == 1);
    if (found.isNotEmpty) {
      final key = found.first;
      return UserKey(
        keyID: key.keyId,
        privateKey: key.privateKey,
        passphrase: passphrase,
      );
    }

    if (userKeyID == "" || privateKey == "" || passphrase == "") {
      throw Exception(
        "First key is null, cannot decrypt wallet key. relogin  or debug.",
      );
    }
    return UserKey(
      keyID: userKeyID,
      privateKey: privateKey,
      passphrase: passphrase,
    );
  }

  Future<UserKey> getUserKey(String keyID) async {
    final userKeyID = userInfo.userKeyID;
    final privateKey = userInfo.userPrivateKey;
    final passphrase = userInfo.userPassphrase;
    final keys = await userDataProvider.getUserKeys(userID);
    final found = keys.where((item) => item.keyId == keyID);
    if (found.isNotEmpty) {
      final key = found.first;
      return UserKey(
        keyID: key.keyId,
        privateKey: key.privateKey,
        passphrase: passphrase,
      );
    }
    if (userKeyID == "" || privateKey == "" || passphrase == "") {
      throw Exception(
          "First key is null, cannot decrypt wallet key. relogin  or debug.");
    }
    return UserKey(
      keyID: userKeyID,
      privateKey: privateKey,
      passphrase: passphrase,
    );
  }

  Future<List<ProtonUserKey>> getUserKeysForTL() async {
    final keys = await userDataProvider.getUserKeys(userID);
    if (keys.isEmpty) {
      throw Exception(
        "Can't find any user keys",
      );
    }
    return keys.toProtonUserKeys();
  }

  Future<ProtonUserKey> getUserKeyForTL(String keyID) async {
    final userKeyID = userInfo.userKeyID;
    final privateKey = userInfo.userPrivateKey;
    final keys = await getUserKeysForTL();
    final found = keys.where((item) => item.id == keyID);
    if (found.isNotEmpty) {
      final key = found.first;
      return key;
    }
    if (userKeyID == "" || privateKey == "") {
      throw Exception(
          "First key is null, cannot decrypt wallet key. relogin  or debug.");
    }
    return ProtonUserKey(
      id: userKeyID,
      privateKey: privateKey,
      version: 4,
      fingerprint: '',
      primary: 1,
      active: 1,
    );
  }

  String getUserKeyPassphrase() {
    return userInfo.userPassphrase;
  }

  Future<List<UserKey>> getUserKeys() async {
    final passphrase = userInfo.userPassphrase;
    final keys = await userDataProvider.getUserKeys(userID);
    if (keys.isEmpty) {
      throw Exception(
        "Can't find any user keys",
      );
    }
    final found = keys
        .map(
          (item) => UserKey(
            keyID: item.keyId,
            privateKey: item.privateKey,
            passphrase: passphrase,
          ),
        )
        .toList();
    return found;
  }

  /// wallet operation

  /// funcations
  @override
  Future<void> init() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> logout() async {
    await storage.deleteAll();
    await shared.logout();
  }

  Future<void> clear() async {
    final map = shared.toMap();
    for (var entry in map.entries) {
      final key = entry.key;
      if (key.toString().startsWith(PreferenceKeys.bdkFullSyncedPrefix)) {
        await shared.delete(key);
      }
    }
    await shared.delete(PreferenceKeys.eventLoopErrorCount);
    await shared.delete(PreferenceKeys.syncErrorCount);
    await shared.delete(PreferenceKeys.syncErrorTimer);
  }

  @override
  Future<void> reload() async {}

  @override
  Future<void> login(String userID) async {
    userDataProvider = UserDataProvider(
      apiServiceManager.getProtonUsersApiClient(),
      UserQueries(dbConnection),
      UserKeysQueries(dbConnection),
    );
  }

  @override
  Priority getPriority() {
    return Priority.level3;
  }
}

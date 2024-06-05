import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/users/user.manager.event.dart';
import 'package:wallet/managers/users/user.manager.state.dart';
import 'package:wallet/models/native.session.model.dart';
import 'package:wallet/rust/proton_api/auth_credential.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;

class UserKey {
  final String keyID;
  final String privateKey;
  final String passphrase;
  UserKey(
      {required this.keyID,
      required this.privateKey,
      required this.passphrase});
}

class UserManager extends Bloc<UserManagerEvent, UserManagerState>
    implements Manager {
  final SecureStorageManager storage;
  final PreferencesManager shared;
  late UserInfo userInfo;
  final ApiEnv apiEnv;

  // api service here
  final ProtonApiServiceManager apiServiceManager;

  UserManager(
    this.storage,
    this.shared,
    this.apiEnv,
    this.apiServiceManager,
  ) : super(UserManagerInitial());

  /// Login and session management
  Future<bool> sessionExists() async {
    await firstRun();
    return await storage.get("sessionId") != "";
  }

  Future<void> login(UserInfo userInfo) async {
    this.userInfo = userInfo;
    // save
    await trySaveUserInfo();
  }

  Future<void> flutterLogin(AuthCredential auth) async {
    userInfo = UserInfo.fromAuth(auth);
    // save
    await trySaveUserInfo();
  }

  Future<void> firstRun() async {
    await shared.checkif('firstTimeEntry', false, () async {
      await storage.deleteAll();
    });
    // check the app first time run
    // if (shared.getBool('firstTimeEntry') ?? true) {
    //   await storage.deleteAll();
    //   await shared.setBool('firstTimeEntry', false);
    // }

    // shared.checkAndRunLogic()
    // add more
  }

  Future<FlutterSession> getChildSession() async {
    var childSession = await proton_api.fork();
    return FlutterSession(
        userId: userInfo.userId,
        userName: userInfo.userName,
        sessionId: childSession.sessionId,
        accessToken: childSession.accessToken,
        refreshToken: childSession.refreshToken,
        scopes: childSession.scopes,
        passphrase: "");
  }

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

  Future<UserKey> getFirstKey() async {
    return UserKey(
        keyID: userInfo.userKeyID,
        privateKey: userInfo.userPrivateKey,
        passphrase: userInfo.userPassphrase);
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
  }
}
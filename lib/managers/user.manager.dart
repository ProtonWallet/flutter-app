import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/user.manager.event.dart';
import 'package:wallet/managers/user.manager.state.dart';
import 'package:wallet/models/native.session.model.dart';
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
  final SharedPreferences shared;
  late UserInfo userInfo;
  final ApiEnv apiEnv;

  UserManager(this.storage, this.shared, this.apiEnv)
      : super(UserManagerInitial());

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

  Future<void> firstRun() async {
    // check the app first time run
    if (shared.getBool('firstTimeEntry') ?? true) {
      await storage.deleteAll();
      shared.setBool('firstTimeEntry', false);
    }
    // add more
  }

  // TODO:: clean up this function
  Future<void> initMuon() async {
    String scopes = userInfo.scopes;
    String uid = userInfo.sessionId;
    String accessToken = userInfo.accessToken;
    String refreshToken = userInfo.refreshToken;
    String appVersion = "Other";
    String userAgent = "None";

    logger.i("uid = '$uid';");
    logger.i("accessToken = '$accessToken';");
    logger.i("refreshToken = '$refreshToken';");
    if (Platform.isAndroid) {
      // TODO:: get from native android
      appVersion = "android-wallet@1.0.0";
      userAgent = "ProtonWallet/1.0.0 (Android 12; test; motorola; en)";
    }
    if (Platform.isIOS) {
      appVersion = "android-wallet@1.0.0";
      userAgent = "ProtonWallet/1.0.0 (iOS/17.4; arm64)";
    }

    await proton_api.initApiServiceAuthStore(
      uid: uid,
      access: accessToken,
      refresh: refreshToken,
      scopes: scopes.split(","),
      appVersion: appVersion,
      userAgent: userAgent,
      env: apiEnv.toString(),
    );
  }

  Future<FlutterSession> getChildSession() async {
    // TODO:: add the logic to get child session, either get from cache or from server api
    return FlutterSession(
        userId: userInfo.userId,
        userName: userInfo.userName,
        sessionId: userInfo.sessionId,
        accessToken: userInfo.accessToken,
        refreshToken: userInfo.refreshToken,
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

  Future<void> logout() async {
    // TODO:: remove all user info from memory
    await storage.deleteAll();
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
}

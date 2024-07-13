import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/extension/data.dart';
import 'package:wallet/helper/extension/strings.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/users/user.manager.event.dart';
import 'package:wallet/managers/users/user.manager.state.dart';
import 'package:wallet/models/native.session.model.dart';
import 'package:wallet/rust/api/proton_api.dart' as proton_api;
import 'package:wallet/rust/proton_api/auth_credential.dart';

class UserKey {
  final String keyID;
  final String privateKey;
  final String passphrase;

  UserKey(
      {required this.keyID,
      required this.privateKey,
      required this.passphrase});

  String decryptBinary(String? binaryEncryptedString) {
    if (binaryEncryptedString != null) {
      final Uint8List bytes = proton_crypto.decryptBinary(
          privateKey, passphrase, binaryEncryptedString.base64decode());
      final String decryptedMessage = utf8.decode(bytes);
      if (decryptedMessage != "null") {
        return decryptedMessage;
      }
    }
    return "";
  }

  String decrypt(String encryptedArmor) {
    return proton_crypto.decrypt(privateKey, passphrase, encryptedArmor);
  }

  String encrypt(String plainText) {
    return proton_crypto.encrypt(privateKey, plainText);
  }

  String encryptBinary(Uint8List data) {
    return proton_crypto.encryptBinary(privateKey, data).base64encode();
  }
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

  String get userID => userInfo.userId;

  Future<void> firstRun() async {
    await shared.isFirstTimeEntry(() async {
      await storage.deleteAll();
    });
    // shared.checkAndRunLogic()
    // add more
  }

  Future<FlutterSession> getChildSession() async {
    final childSession = await proton_api.fork();
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

  Future<UserKey> getFirstKey() async {
    final userKeyID = userInfo.userKeyID;
    final privateKey = userInfo.userPrivateKey;
    final passphrase = userInfo.userPassphrase;
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

  @override
  Future<void> login(String userID) {
    // TODO(fix): implement login
    throw UnimplementedError();
  }
}

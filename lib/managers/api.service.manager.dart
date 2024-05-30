import 'dart:io';

import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/rust/api/api_service/proton_api_service.dart';
import 'package:wallet/rust/api/api_service/wallet_auth_store.dart';
import 'package:wallet/rust/proton_api/auth_credential.dart';

class ProtonApiServiceManager implements Manager {
  final SecureStorageManager storage;
  final ApiEnv env;

  final String version = "flutter-wallet@1.0.0";
  final String agent = "ProtonWallet/1.0.0 (iOS/17.4; arm64)";

  //
  ProtonApiService? apiService;
  late ProtonWalletAuthStore authStore;

  // add networking service here
  ProtonApiServiceManager(this.env, {required this.storage}) {
    authStore = ProtonWalletAuthStore(env: env.toString());
  }

  Future<String> callback(ChildSession session) async {
    logger.w("Received message from Rust: $session");
    await saveSession(session);
    return "Reply from Dart";
  }

  Future<void> saveSession(ChildSession session) async {
    // Notes:: the user manager saving the session in parallel make sure await each other
    // TODO:: merge this with user manager.dart. maybe have a different class to handle session only
    await storage.set("sessionId", session.sessionId);
    await storage.set("accessToken", session.accessToken);
    await storage.set("refreshToken", session.refreshToken);
    await storage.set("scopes", session.scopes.join(","));
  }

  Future<void> initalOldApiService() async {
    // Notes:: the user manager saving the session in parallel make sure await each other
    String scopes = await storage.get("scopes");
    String uid = await storage.get("sessionId");
    String accessToken = await storage.get("accessToken");
    String refreshToken = await storage.get("refreshToken");
    String appVersion = "Other";
    String userAgent = "None";
    logger.i("uid = '$uid';");
    logger.i("accessToken = '$accessToken';");
    logger.i("refreshToken = '$refreshToken';");
    if (Platform.isAndroid) {
      appVersion = "android-wallet@1.0.0";
      userAgent = "ProtonWallet/1.0.0 (Android 12; test; motorola; en)";
    }
    if (Platform.isIOS) {
      appVersion = "android-wallet@1.0.0";
      userAgent = "ProtonWallet/1.0.0 (iOS/17.4; arm64)";
    }

    authStore = ProtonWalletAuthStore.fromSession(
        env: env.toString(),
        uid: uid,
        access: accessToken,
        refresh: refreshToken,
        scopes: scopes.split(","));
    await authStore.setAuthDartCallback(callback: callback);
    apiService = ProtonApiService.initApiServiceAuthStore(
        appVersion: appVersion, userAgent: userAgent, store: authStore);
  }

  ProtonApiService getApiService() {
    // final info = await PackageInfo.fromPlatform();
    // final appVersion = '${info.version} (${info.buildNumber})';
    // final userAgent =
    //     'ProtonWallet/${info.version} (${Platform.operatingSystem}/${Platform.operatingSystemVersion}; ${Platform.localeName})';
    apiService ??= ProtonApiService(store: authStore);
    return apiService!;
  }

  Future<void> logout() async {
    apiService = null;
  }

  Future<void> buildAndRestore() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {
    await authStore.setAuthDartCallback(callback: callback);
    apiService = ProtonApiService(store: authStore);
  }
}

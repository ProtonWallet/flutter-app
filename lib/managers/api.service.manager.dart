import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/user.agent.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/rust/api/api_service/proton_api_service.dart';
import 'package:wallet/rust/api/api_service/proton_email_addr_client.dart';
import 'package:wallet/rust/api/api_service/proton_settings_client.dart';
import 'package:wallet/rust/api/api_service/proton_users_client.dart';
import 'package:wallet/rust/api/api_service/wallet_auth_store.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/proton_api/auth_credential.dart';

class ProtonApiServiceManager implements Manager {
  final SecureStorageManager storage;
  final ApiEnv env;

  String version = "macos-wallet@1.0.0";
  String agent = "ProtonWallet/1.0.0 (iOS/17.4; arm64)";

  ///
  ProtonApiService? _apiService;
  late ProtonWalletAuthStore authStore;

  /// add networking service here
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
    // TODO(fix): merge this with user manager.dart. maybe have a different class to handle session only
    await storage.set("sessionId", session.sessionId);
    await storage.set("accessToken", session.accessToken);
    await storage.set("refreshToken", session.refreshToken);
    await storage.set("scopes", session.scopes.join(","));
  }

  Future<void> initalOldApiService() async {
    // Notes:: the user manager saving the session in parallel make sure await each other
    final String scopes = await storage.get("scopes");
    final String uid = await storage.get("sessionId");
    final String accessToken = await storage.get("accessToken");
    final String refreshToken = await storage.get("refreshToken");
    logger.i("sessionId = '$uid';");
    logger.i("accessToken = '$accessToken';");
    logger.i("refreshToken = '$refreshToken';");

    final apiService = _apiService;
    if (apiService != null) {
      logger.w("ApiService already initalized, updating the session");
      await apiService.updateAuth(
          uid: uid,
          access: accessToken,
          refresh: refreshToken,
          scopes: scopes.split(","));
    } else {
      authStore = ProtonWalletAuthStore.fromSession(
          env: env.toString(),
          uid: uid,
          access: accessToken,
          refresh: refreshToken,
          scopes: scopes.split(","));
      await authStore.setAuthDartCallback(callback: callback);
      _apiService = ProtonApiService(
          env: env.toString(),
          appVersion: version,
          userAgent: agent,
          store: authStore);
    }
    await _apiService?.setProtonApi();
  }

  ProtonApiService getApiService() {
    _apiService ??= ProtonApiService(
        env: env.toString(),
        appVersion: version,
        userAgent: agent,
        store: authStore);
    return _apiService!;
  }

  Future<void> buildAndRestore() async {}

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {
    await authStore.setAuthDartCallback(callback: callback);

    final UserAgent userAgent = UserAgent();
    version = await userAgent.appVersion;
    agent = await userAgent.ua;

    _apiService = ProtonApiService(
        env: env.toString(),
        appVersion: version,
        userAgent: agent,
        store: authStore);
  }

  @override
  Future<void> logout() async {
    /// the apiSerice logout is global clean up in rust layer. remove the ProtonAPiSerive caches and also reset the AuthStore session.
    ///  after called this function, you need re-init the ProtonApiService again. dont foget to setup AuthDartCallback.
    await _apiService?.logout();
    // _apiService = null;
    // authStore = ProtonWalletAuthStore(env: env.toString());
    // await init();
  }

  @override
  Future<void> login(String userID) {
    // TODO(fix): implement login
    throw UnimplementedError();
  }

  /// # get clients

  /// get user api client
  ProtonEmailAddressClient getProtonEmailAddrApiClient() {
    return getApiService().getProtonEmailAddrClient();
  }

  ProtonUsersClient getProtonUsersApiClient() {
    return getApiService().getProtonUserClient();
  }

  /// get wallet api client
  WalletClient getWalletClient() {
    return getApiService().getWalletClient();
  }

  ProtonSettingsClient getSettingsApiClient() {
    return getApiService().getProtonSettingsClient();
  }
}

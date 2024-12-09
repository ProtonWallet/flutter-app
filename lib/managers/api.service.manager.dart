import 'package:wallet/constants/env.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/user.agent.dart';
import 'package:wallet/managers/manager.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/rust/api/api_service/proton_api_service.dart';
import 'package:wallet/rust/api/api_service/proton_email_addr_client.dart';
import 'package:wallet/rust/api/api_service/proton_settings_client.dart';
import 'package:wallet/rust/api/api_service/proton_users_client.dart';
import 'package:wallet/rust/api/api_service/settings_client.dart';
import 'package:wallet/rust/api/api_service/transaction_client.dart';
import 'package:wallet/rust/api/api_service/unleash_client.dart';
import 'package:wallet/rust/api/api_service/wallet_auth_store.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/proton_api/auth_credential.dart';

class ProtonApiServiceManager implements Manager {
  final SecureStorageManager storage;
  final ApiEnv env;

  final userAgent = UserAgent();

  String? userID;

  ///
  ProtonApiService? _apiService;
  late ProtonWalletAuthStore authStore;

  /// add networking service here
  ProtonApiServiceManager(this.env, {required this.storage}) {
    authStore = ProtonWalletAuthStore(env: env.toString());
  }

  Future<String> callback(ChildSession session) async {
    logger.i("Received message from Rust: ${session.sessionId}");
    await saveSession(session);
    return "Reply from Dart";
  }

  Future<void> saveSession(ChildSession session) async {
    // Notes:: the user manager saving the session in parallel make sure await each other
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

    final apiService = _apiService;
    final appVersion = await userAgent.appVersion;
    final ua = await userAgent.ua;
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
          appVersion: appVersion,
          userAgent: ua,
          store: authStore);
    }
    await _apiService?.setProtonApi();
  }

  ProtonApiService getApiService() {
    return _apiService!;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> init() async {
    await authStore.setAuthDartCallback(callback: callback);
  }

  @override
  Future<void> logout() async {
    userID = null;

    /// the apiSerice logout is global clean up in rust layer. remove the ProtonAPiSerive caches and also reset the AuthStore session.
    ///  after called this function, you need re-init the ProtonApiService again. dont foget to setup AuthDartCallback.
    await _apiService?.logout();
    _apiService = null;
  }

  @override
  Future<void> login(String userID) async {
    this.userID = userID;
    await initalOldApiService();
  }

  @override
  Future<void> reload() async {}

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

  ProtonSettingsClient getProtonSettingsApiClient() {
    return getApiService().getProtonSettingsClient();
  }

  SettingsClient getSettingsClient() {
    return getApiService().getSettingsClient();
  }

  TransactionClient getTransactionClient() {
    return getApiService().getTransactionClient();
  }

  FrbUnleashClient getUnleashClient() {
    return getApiService().getUnleashClient();
  }

  @override
  Priority getPriority() {
    return Priority.level2;
  }
}

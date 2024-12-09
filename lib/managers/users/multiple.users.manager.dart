// Define a class to manage multiple UserManager instances
import 'package:wallet/constants/env.dart';
import 'package:wallet/managers/api.service.manager.dart';
import 'package:wallet/managers/preferences/preferences.manager.dart';
import 'package:wallet/managers/secure.storage/secure.storage.manager.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/models/native.session.model.dart';
import 'package:wallet/rust/proton_api/auth_credential.dart';

class MultipleUsersManager {
  final SecureStorageManager storage;
  final PreferencesManager shared;
  final ApiEnv apiEnv;
  final ProtonApiServiceManager apiServiceManager;

  final Map<String, UserManager> _userManagers = {};

  MultipleUsersManager(
    this.storage,
    this.shared,
    this.apiEnv,
    this.apiServiceManager,
  );

  Future<void> login(String userId, AuthCredential auth) async {}

  Future<void> nativeLogin(UserInfo userInfo) async {}

  Future<void> logout(String userId) async {
    final userManager = _userManagers[userId];
    if (userManager != null) {
      await userManager.logout();
      _userManagers.remove(userId);
    }
  }

  UserManager? getUserManager(String userId) {
    return _userManagers[userId];
  }
}

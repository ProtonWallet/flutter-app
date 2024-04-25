import 'package:flutter/cupertino.dart';
import 'package:wallet/helper/secure_storage_helper.dart';

class UserSession {
  String userId = "";
  String userMail = "";
  String userName = "";
  String userDisplayName = "";
  String sessionId = "";
  String accessToken = "";
  String refreshToken = "";
  String scopes = "";
  String userKeyID = "";
  String userPrivateKey = "";
  String userPassphrase = "";
}

class UserSessionProvider with ChangeNotifier {
  final UserSession _userSession = UserSession();

  UserSession get userSession => _userSession;

  Future<void> login(
      {required String userId,
      required String userMail,
      required String userName,
      required String userDisplayName,
      required String sessionId,
      required String accessToken,
      required String refreshToken,
      required String scopes,
      required String userKeyID,
      required String userPrivateKey,
      required String userPassphrase}) async {
    _userSession.userId = userId;
    _userSession.userMail = userMail;
    _userSession.userName = userName;
    _userSession.userDisplayName = userDisplayName;
    _userSession.sessionId = sessionId;
    _userSession.accessToken = accessToken;
    _userSession.refreshToken = refreshToken;
    _userSession.scopes = scopes;
    _userSession.userKeyID = userKeyID;
    _userSession.userPrivateKey = userPrivateKey;
    _userSession.userPassphrase = userPassphrase;
    await SecureStorageHelper.instance.set("userId", userId);
    await SecureStorageHelper.instance.set("userMail", userMail);
    await SecureStorageHelper.instance.set("userName", userName);
    await SecureStorageHelper.instance.set("userDisplayName", userDisplayName);
    await SecureStorageHelper.instance.set("sessionId", sessionId);
    await SecureStorageHelper.instance.set("accessToken", accessToken);
    await SecureStorageHelper.instance.set("refreshToken", refreshToken);
    await SecureStorageHelper.instance.set("scopes", scopes);
    await SecureStorageHelper.instance.set("userKeyID", userKeyID);
    await SecureStorageHelper.instance.set("userPrivateKey", userPrivateKey);
    await SecureStorageHelper.instance.set("userPassphrase", userPassphrase);
    notifyListeners();
  }

  Future<void> logout() async {
    _userSession.userId = "";
    _userSession.userMail = "";
    _userSession.userName = "";
    _userSession.userDisplayName = "";
    _userSession.sessionId = "";
    _userSession.accessToken = "";
    _userSession.refreshToken = "";
    _userSession.scopes = "";
    _userSession.userKeyID = "";
    _userSession.userPrivateKey = "";
    _userSession.userPassphrase = "";
    await SecureStorageHelper.instance.deleteAll();
    notifyListeners();
  }
}

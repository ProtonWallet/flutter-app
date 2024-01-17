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
  String userKeyID = "";
}

class UserSessionProvider with ChangeNotifier {
  final UserSession _userSession = UserSession();

  UserSession get userSession => _userSession;

  void login(
      String userId,
      String userMail,
      String userName,
      String userDisplayName,
      String sessionId,
      String accessToken,
      String refreshToken,
      String userKeyID) {
    _userSession.userId = userId;
    _userSession.userMail = userMail;
    _userSession.userName = userName;
    _userSession.userDisplayName = userDisplayName;
    _userSession.sessionId = sessionId;
    _userSession.accessToken = accessToken;
    _userSession.refreshToken = refreshToken;
    _userSession.userKeyID = userKeyID;
    SecureStorageHelper.set("userId", userId);
    SecureStorageHelper.set("userMail", userMail);
    SecureStorageHelper.set("userName", userName);
    SecureStorageHelper.set("userDisplayName", userDisplayName);
    SecureStorageHelper.set("sessionId", sessionId);
    SecureStorageHelper.set("accessToken", accessToken);
    SecureStorageHelper.set("refreshToken", refreshToken);
    SecureStorageHelper.set("userKeyID", userKeyID);
    notifyListeners();
  }

  void logout() {
    _userSession.userId = "";
    _userSession.userMail = "";
    _userSession.userName = "";
    _userSession.userDisplayName = "";
    _userSession.sessionId = "";
    _userSession.accessToken = "";
    _userSession.refreshToken = "";
    _userSession.userKeyID = "";
    SecureStorageHelper.deleteAll();
    notifyListeners();
  }
}

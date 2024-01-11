import 'package:flutter/cupertino.dart';

class UserSession {
  String userId = "";
  String userMail = "";
  String userName = "";
  String userDisplayName = "";
  String sessionId = "";
  String accessToken = "";
  String refreshToken = "";
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
      String refreshToken) {
    _userSession.userId = userId;
    _userSession.userMail = userMail;
    _userSession.userName = userName;
    _userSession.userDisplayName = userDisplayName;
    _userSession.sessionId = sessionId;
    _userSession.accessToken = accessToken;
    _userSession.refreshToken = refreshToken;
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
    notifyListeners();
  }
}

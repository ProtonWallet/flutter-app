typedef NavigationIdentifier = int;

abstract class NavigationIdentifiers {
  static const NavigationIdentifier root = 0;
}

abstract class ViewIdentifiers extends NavigationIdentifiers {
  static const NavigationIdentifier welcome = 1;
  static const NavigationIdentifier home = 2;
  static const NavigationIdentifier send = 3;
  static const NavigationIdentifier receive = 4;
  static const NavigationIdentifier historyDetails = 5;
  static const NavigationIdentifier setupOnboard = 6;
  static const NavigationIdentifier setupCreate = 7;
  static const NavigationIdentifier setupBackup = 8;
  static const NavigationIdentifier importWallet = 9;
  static const NavigationIdentifier wallet = 10;
  static const NavigationIdentifier history = 11;
  static const NavigationIdentifier passphrase = 12;
  static const NavigationIdentifier setupReady = 13;
  static const NavigationIdentifier mailList = 14;
  static const NavigationIdentifier mailEdit = 15;
  static const NavigationIdentifier walletDeletion = 16;
  static const NavigationIdentifier sendReview = 17;
  static const NavigationIdentifier twoFactorAuthSetup = 18;
  static const NavigationIdentifier twoFactorAuthDisable = 19;
  static const NavigationIdentifier nativeSignin = 20;
  static const NavigationIdentifier nativeSignup = 21;
  static const NavigationIdentifier signin = 22;
  static const NavigationIdentifier signup = 23;
  static const NavigationIdentifier discover = 24;
  static const NavigationIdentifier testWallet = 100;
  static const NavigationIdentifier testWebsocket = 101;
  static const NavigationIdentifier newuser = 200;

  void move(NavigationIdentifier to);
}

//
abstract class NavigationFlowInterface {
  Future<void> move(NavID to);
}

enum NavID {
  root,
  setupBackup,
  setupReady,

  // Wallet
  wallet, //????
  importWallet,

  // Home and Welcome
  welcome,
  home,

  // Transactions
  send,
  sendReview,
  receive,
  history,
  historyDetails,
  // buy
  buy,
  rampExternal,
  banaxExternal,
  // upgrade
  nativeUpgrade,
  // Report bugs
  natvieReportBugs,

  // Security
  passphrase,
  twoFactorAuthSetup,
  twoFactorAuthDisable,
  securitySetting,
  recovery,

  // Mail integration
  mailList,
  mailEdit,

  // Auth/Login/Signup
  nativeSignin,
  nativeSignup,
  signin,
  signup,

  // Feeds
  discover,

  // Settings
  settings,
  logs,

  // Others
  testWallet,
  testWebsocket,
  newuser,
}

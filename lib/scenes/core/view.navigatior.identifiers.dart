//
abstract class NavigationFlowInterface {
  void move(NavID to);
}

enum NavID {
  root,

  // Setup & Import
  setupOnboard,
  setupCreate,
  setupBackup,
  setupReady,

  // Wallet
  wallet, //????
  importWallet,
  walletDeletion,

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
  // upgrade
  nativeUpgrade,

  // Security
  passphrase,
  twoFactorAuthSetup,
  twoFactorAuthDisable,
  securitySetting,

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

  // Others
  testWallet,
  testWebsocket,
  newuser,
}

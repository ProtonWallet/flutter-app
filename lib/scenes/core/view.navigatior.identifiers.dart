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

  // Home sub views
  addWalletAccount,
  acceptTermsConditionDialog,
  protonProducts,
  upgrade,
  sendInvite,
  secureYourWallet,
  importSuccess,
  deleteWalletAccount,
  walletAccountAddressList,
  walletAccountInfo,
  walletAccountXpubInfo,
  walletAccountStatementExport,

  // Transactions
  send,
  sendReview,
  receive,
  history,
  historyDetails,
  // buy
  buy,
  buyUnavailable,
  rampExternal,
  banaxExternal,
  moonpayExternal,

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
  logout,

  // Feeds
  discover,

  // RBF
  rbf,

  // Settings
  settings,
  logs,

  // import Paper wallet
  importPaperWallet,

  // Others
  testWallet,
  newuser,
}

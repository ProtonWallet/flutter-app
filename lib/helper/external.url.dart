import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class ExternalUrl {
  // Private constructor
  ExternalUrl._privateConstructor();

  // Static instance
  static final ExternalUrl _instance = ExternalUrl._privateConstructor();

  // Named constructor to return the singleton instance
  static ExternalUrl get shared => _instance;

  // Final variable for account URL
  final String accountUrl = "https://account.proton.me";
  final String mainSiteUrl = "https://proton.me/";
  final String supportCenterUrl = "https://proton.me/support/wallet";
  final String terms = "https://proton.me/wallet/legal/terms";
  final String privacy = "https://proton.me/wallet/privacy-policy";

  final String seedPhraseLink =
      "https://proton.me/support/wallet-protection#seed-phrase";
  final String bveAcitvedLink =
      "https://proton.me/support/wallet-bitcoin-via-email";
  final String bveInAcitvedLink =
      "https://proton.me/support/wallet-bitcoin-via-email#how-to-enable-bitcoin-via-email";

  // final String inviteFriendLink = "https://proton.me/support/wallet-how-to-invite-people";
  final String optionalPassphraseLink =
      "https://proton.me/support/wallet-protection#optional-passphrase";
  final String addressTypeLink =
      "https://proton.me/support/wallet-create-btc-account#bitcoin-address-type";
  final String accountIndexLink =
      "https://proton.me/support/wallet-create-btc-account#bitcoin-account-index-type";

  /// android app store url
  final String googlePlayUrl =
      "https://play.google.com/store/apps/dev?id=7672479706558526647";

  /// ios app store url
  final String appStoreUrl =
      "https://apps.apple.com/developer/proton-ag/id979659484";

  final String upgradeRequired = "https://proton.me/support/update-required";

  // Method to launch a URL
  void launchString(String strUrl) {
    launchUrl(Uri.parse(strUrl));
  }

  void lanuchMainSite() {
    launchString(mainSiteUrl);
  }

  // Method to launch the Proton account URL
  void launchProtonAccount() {
    launchString(accountUrl);
  }

  void launchBlogSeedPhrase() {
    launchString(seedPhraseLink);
  }

  void launchBlogBvEActivated() {
    launchString(bveAcitvedLink);
  }

  void launchBlogBvEInActivated() {
    launchString(bveInAcitvedLink);
  }

  void launchBlogPassphrase() {
    launchString(optionalPassphraseLink);
  }

  void launchBlogAddressType() {
    launchString(addressTypeLink);
  }

  void launchBlogAccountIndex() {
    launchString(accountIndexLink);
  }

  void launchProtonHelpCenter() {
    launchString(supportCenterUrl);
  }

  void lanuchTerms() {
    launchString(terms);
  }

  void lanuchPrivacy() {
    launchString(privacy);
  }

  void lanuchGooglePlay() {
    launchString(googlePlayUrl);
  }

  void lanuchAppStore() {
    launchString(appStoreUrl);
  }

  void lanuchStore() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      lanuchGooglePlay();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      lanuchAppStore();
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      lanuchAppStore();
    } else {
      lanuchMainSite();
    }
  }

  void lanuchForceUpgradeLearnMore() {
    launchString(upgradeRequired);
  }
}

import 'dart:io';

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
  final String walletHomepage = "https://wallet.proton.me";

  final String seedPhraseLink =
      "https://proton.me/support/wallet-protection#seed-phrase";
  final String bveAcitvedLink =
      "https://proton.me/support/wallet-bitcoin-via-email";
  final String bveInAcitvedLink =
      "https://proton.me/support/wallet-bitcoin-via-email#how-to-enable-bitcoin-via-email";
  final String optionalPassphraseLink =
      "https://proton.me/support/wallet-protection#optional-passphrase";
  final String addressTypeLink =
      "https://proton.me/support/wallet-create-btc-account#bitcoin-address-type";
  final String accountIndexLink =
      "https://proton.me/support/wallet-create-btc-account#bitcoin-account-index-type";
  final String importWalletLink = "https://proton.me/support/wallet-import-wallet";

  /// android app store url
  final String googlePlayUrl =
      "https://play.google.com/store/apps/dev?id=7672479706558526647";

  /// ios app store url
  final String appStoreUrl =
      "https://apps.apple.com/developer/proton-ag/id979659484";

  final String upgradeRequired = "https://proton.me/support/update-required";

  final String protonMailGooglePlayUrl =
      "https://play.google.com/store/apps/details?id=ch.protonmail.android";

  final String protonCalendarGooglePlayUrl =
      "https://play.google.com/store/apps/details?id=me.proton.android.calendar";

  final String protonDriveGooglePlayUrl =
      "https://play.google.com/store/apps/details?id=me.proton.android.drive";

  final String protonPassGooglePlayUrl =
      "https://play.google.com/store/apps/details?id=proton.android.pass";

  final String protonMailAppStoreUrl =
      "https://apps.apple.com/us/app/proton-mail-encrypted-email/id979659905";

  final String protonCalendarAppStoreUrl =
      "https://apps.apple.com/us/app/proton-calendar-secure-events/id1514709943";

  final String protonDriveAppStoreUrl =
      "https://apps.apple.com/us/app/proton-drive-photo-backup/id1509667851";

  final String protonPassAppStoreUrl =
      "https://apps.apple.com/us/app/proton-pass-password-manager/id6443490629";

  final String protonMailUrl = "https://proton.me/mail";
  final String protonCalendarUrl = "https://proton.me/calendar";
  final String protonDriveUrl = "https://proton.me/drive";
  final String protonPassUrl = "https://proton.me/pass";
  final String protonForBusinessUrl = "https://proton.me/business";

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

  void launchBlogImportWallet(){
    launchString(importWalletLink);
  }

  void launchWalletHomepage() {
    launchString(walletHomepage);
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

  void launchProtonMail() {
    if (Platform.isAndroid) {
      launchString(protonMailGooglePlayUrl);
    } else if (Platform.isIOS) {
      launchString(protonMailAppStoreUrl);
    } else {
      launchString(protonMailUrl);
    }
  }

  void launchProtonCalendar() {
    if (Platform.isAndroid) {
      launchString(protonCalendarGooglePlayUrl);
    } else if (Platform.isIOS) {
      launchString(protonCalendarAppStoreUrl);
    } else {
      launchString(protonCalendarUrl);
    }
  }

  void launchProtonDrive() {
    if (Platform.isAndroid) {
      launchString(protonDriveGooglePlayUrl);
    } else if (Platform.isIOS) {
      launchString(protonDriveAppStoreUrl);
    } else {
      launchString(protonDriveUrl);
    }
  }

  void launchProtonPass() {
    if (Platform.isAndroid) {
      launchString(protonPassGooglePlayUrl);
    } else if (Platform.isIOS) {
      launchString(protonPassAppStoreUrl);
    } else {
      launchString(protonPassUrl);
    }
  }

  void launchProtonForBusiness() {
    launchString(protonForBusinessUrl);
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

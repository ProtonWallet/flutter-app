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
  final String supportCenterUrl = "https://proton.me/support";
  final String terms = "https://proton.me/wallet/legal/terms";
  final String privacy = "https://proton.me/wallet/privacy-policy";

  /// android app store url
  final String googlePlayUrl =
      "https://play.google.com/store/apps/dev?id=7672479706558526647";

  /// ios app store url
  final String appStoreUrl =
      "https://apps.apple.com/developer/proton-ag/id979659484";

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
}

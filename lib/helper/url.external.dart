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
  final String supportCenterUrl = "https://proton.me/support";
  final String terms = "https://proton.me/legal/terms";
  final String privacy = "https://proton.me/legal/privacy";

  // Method to launch a URL
  void launchString(String strUrl) {
    launchUrl(Uri.parse(strUrl));
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
}

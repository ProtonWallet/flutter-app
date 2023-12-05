import 'package:wallet/scenes/core/view.navigator.dart';

abstract class ViewIdentifiers extends NavigationIdentifiers {
  static const NavigationIdentifier root = 0;
  static const NavigationIdentifier welcome = 1;
  static const NavigationIdentifier home = 2;
  static const NavigationIdentifier send = 3;
  static const NavigationIdentifier receive = 4;
  static const NavigationIdentifier historyDetails = 5;
  static const NavigationIdentifier setupOnboard = 6;
  static const NavigationIdentifier testwallet = 7;
}

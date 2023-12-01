import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/view.dart';

typedef NavigationIdentifier = int;

abstract class NavigationIdentifiers {
  static const NavigationIdentifier none = 0;
}

abstract class ViewNavigator {
  ViewNavigator();

  ViewBase move(NavigationIdentifier to, BuildContext context);
}

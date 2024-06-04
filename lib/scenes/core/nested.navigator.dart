import 'package:flutter/material.dart';

/// nested Navigator. helper build nested navigator for drawer and navigation
///   switching beteen large screen and small screen
class NestedNavigator extends StatefulWidget {
  final WidgetBuilder builder;
  final GlobalKey<NavigatorState>? navigatorKey;

  const NestedNavigator({
    super.key,
    required this.navigatorKey,
    required this.builder,
  });

  @override
  NavigatorManagerState createState() => NavigatorManagerState();
}

class NavigatorManagerState extends State<NestedNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: widget.builder,
          settings: settings,
        );
      },
    );
  }
}

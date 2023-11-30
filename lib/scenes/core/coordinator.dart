import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view_navigator.dart';

abstract class Coordinator implements ViewNavigator {
  Coordinator();

  ViewBase start();

  void end();
}

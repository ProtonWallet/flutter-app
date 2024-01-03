import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigator.dart';

abstract class Coordinator implements ViewNavigator {
  Coordinator();

  ViewBase start({Map<String, String> params = const {}});

  void end();

  List<ViewBase> starts() {
    throw UnimplementedError();
  }
}

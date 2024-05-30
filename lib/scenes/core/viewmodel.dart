import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/helper/extension/platform.extension.dart';

abstract class ViewModel<T extends Coordinator>
    extends NavigationFlowInterface {
  ViewModel(this.coordinator);
  final T coordinator;
  Stream<ViewModel> get datasourceChanged;
  void dispose();
  Future<void> loadData();
  bool get keepAlive => false;

  bool get mobile => PlatformExtension.mobile;

  bool get desktop => PlatformExtension.desktop;
}

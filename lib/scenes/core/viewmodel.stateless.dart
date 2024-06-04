import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/helper/extension/platform.extension.dart';

abstract class StatelessViewModel<T extends Coordinator> {
  StatelessViewModel(this.coordinator);
  final T coordinator;
  bool get mobile => PlatformExtension.mobile;
  bool get desktop => PlatformExtension.desktop;
}

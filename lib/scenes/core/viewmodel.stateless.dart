import 'package:wallet/helper/extension/platform.extension.dart' as pf_ext;
import 'package:wallet/scenes/core/coordinator.dart';

abstract class StatelessViewModel<T extends Coordinator> {
  StatelessViewModel(this.coordinator);
  final T coordinator;
  bool get mobile => pf_ext.mobile;
  bool get desktop => pf_ext.desktop;
}

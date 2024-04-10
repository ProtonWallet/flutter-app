import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

import 'transfer.view.dart';
import 'transfer.viewmodel.dart';

class TransferCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var viewModel = TransferViewModelImpl(this);
    widget = TransferView(
      viewModel,
    );
    return widget;
  }
}

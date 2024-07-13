import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

import 'two.factor.auth.disable.view.dart';
import 'two.factor.auth.disable.viewmodel.dart';

class TwoFactorAuthDisableCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final viewModel = TwoFactorAuthDisableViewModelImpl(this);
    widget = TwoFactorAuthDisableView(
      viewModel,
    );
    return widget;
  }
}

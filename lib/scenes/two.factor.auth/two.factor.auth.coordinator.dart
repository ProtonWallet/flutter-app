import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

import 'two.factor.auth.view.dart';
import 'two.factor.auth.viewmodel.dart';

class TwoFactorAuthCoordinator extends Coordinator {
  late ViewBase widget;

  TwoFactorAuthCoordinator();

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var viewModel = TwoFactorAuthViewModelImpl(this);
    widget = TwoFactorAuthView(
      viewModel,
    );
    return widget;
  }
}

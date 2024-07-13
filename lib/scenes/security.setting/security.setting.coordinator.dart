import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

import 'package:wallet/scenes/security.setting/security.setting.view.dart';
import 'package:wallet/scenes/security.setting/security.setting.viewmodel.dart';
import 'package:wallet/scenes/two.factor.auth.disable/two.factor.auth.disable.coordinator.dart';
import 'package:wallet/scenes/two.factor.auth/two.factor.auth.coordinator.dart';

class SecuritySettingCoordinator extends Coordinator {
  late ViewBase widget;

  void showTwoFactorAuthSetup() {
    final view = TwoFactorAuthCoordinator().start();
    push(view);
  }

  void showTwoFactorAuthDisable() {
    final view = TwoFactorAuthDisableCoordinator().start();
    push(view);
  }

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    final viewModel = SecuritySettingViewModelImpl(this);
    widget = SecuritySettingView(
      viewModel,
    );
    return widget;
  }
}

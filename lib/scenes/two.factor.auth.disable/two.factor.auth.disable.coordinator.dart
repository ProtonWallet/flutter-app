import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';

import 'two.factor.auth.disable.view.dart';
import 'two.factor.auth.disable.viewmodel.dart';

class TwoFactorAuthDisableCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    throw UnimplementedError();
  }

  @override
  ViewBase<ViewModel> start({Map<String, String> params = const {}}) {
    var viewModel = TwoFactorAuthDisableViewModelImpl(this);
    widget = TwoFactorAuthDisableView(
      viewModel,
    );
    return widget;
  }
}

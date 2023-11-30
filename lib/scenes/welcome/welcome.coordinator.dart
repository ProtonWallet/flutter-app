import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view_model.dart';
import 'package:wallet/scenes/core/view_navigator.dart';
import 'package:wallet/scenes/welcome/welcome.view.dart';
import 'package:wallet/scenes/welcome/welcome.viewmodel.dart';

class WelcomeCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    //     View view = WeootCoordinator().start();
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => view));
    // return view;
    throw UnimplementedError();
  }

  @override
  ViewBase<ViewModel> start() {
    // LoginModelContract loginModelContract = LoginModelImpl();
    // var viewModel = LoginViewModelImpl(
    //   this,
    //   loginModelContract,
    //   InputFeedbackViewModelImpl(this),
    //   InputFeedbackViewModelImpl(this),
    // );
    var viewModel = WelcomeViewModelImpl(this);
    widget = WelcomeView(
      viewModel,
    );
    return widget;
  }
}

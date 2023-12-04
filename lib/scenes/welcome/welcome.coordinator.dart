import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/home/navigation.coordinator.dart';
import 'package:wallet/scenes/welcome/welcome.view.dart';
import 'package:wallet/scenes/welcome/welcome.viewmodel.dart';

class WelcomeCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    var view = HomeNavigationCoordinator().start();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) {
            return view;
          },
          fullscreenDialog: false),
    );
    return view;
  }

  @override
  ViewBase<ViewModel> start() {
    var viewModel = WelcomeViewModelImpl(this);
    widget = WelcomeView(
      viewModel,
    );
    return widget;
  }
}

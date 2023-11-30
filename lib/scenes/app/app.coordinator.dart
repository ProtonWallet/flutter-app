import 'package:flutter/material.dart';
import 'package:wallet/scenes/app/app.view.dart';
import 'package:wallet/scenes/app/app.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view_model.dart';
import 'package:wallet/scenes/core/view_navigator.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';

class AppCoordinator extends Coordinator {
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
    // check cache status

    // if cache is empty, show welcome screen

    // if cache is not empty, show login screen

    ViewBase view = WelcomeCoordinator().start();
    var viewModel = AppViewModelImpl(
      this,
    );
    widget = AppView(
      viewModel,
      view,
    );
    return widget;
  }
}

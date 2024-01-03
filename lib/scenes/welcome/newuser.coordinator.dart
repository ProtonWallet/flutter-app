import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';

import 'newuser.view.dart';
import 'newuser.viewmodel.dart';

class NewUserCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    var view = WelcomeCoordinator().start();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          settings: RouteSettings(name: view.key.toString()),
          builder: (context) {
            return view;
          },
          fullscreenDialog: false),
    );
    return view;
  }

  @override
  ViewBase<ViewModel> start({Map<String, String> params = const {}}) {
    var viewModel = NewUserViewModelImpl(this);
    widget = NewUserView(
      viewModel,
    );
    return widget;
  }
}

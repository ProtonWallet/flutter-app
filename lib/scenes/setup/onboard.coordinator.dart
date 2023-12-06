import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/setup/create.coordinator.dart';
import 'package:wallet/scenes/setup/onboard.view.dart';
import 'package:wallet/scenes/setup/onboard.viewmodel.dart';

class SetupOnbaordCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    if (to == ViewIdentifiers.setupCreate) {
      var view = SetupCreateCoordinator().start();
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) {
              return view;
            },
            fullscreenDialog: false),
      );
      return view;
    }
    throw UnimplementedError();
  }

  @override
  ViewBase<ViewModel> start() {
    var viewModel = SetupOnboardViewModelImpl(this);
    widget = SetupOnboardView(
      viewModel,
    );
    return widget;
  }
}

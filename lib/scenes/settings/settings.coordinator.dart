import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/settings/settings.view.dart';
import 'package:wallet/scenes/settings/settings.viewmodel.dart';

class SettingsCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => view));
    // return view;
    throw UnimplementedError();
  }

  @override
  ViewBase<ViewModel> start() {
    var viewModel = SettingsViewModelImpl(
      this,
    );
    widget = SettingsView(
      viewModel,
    );
    return widget;
  }
}

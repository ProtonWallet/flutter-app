import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/receive/receive.view.dart';
import 'package:wallet/scenes/receive/receive.viewmodel.dart';

class ReceiveCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    throw UnimplementedError();
  }

  @override
  ViewBase<ViewModel> start() {
    var viewModel = ReceiveViewModelImpl(this);
    widget = ReceiveView(
      viewModel,
    );
    return widget;
  }
}

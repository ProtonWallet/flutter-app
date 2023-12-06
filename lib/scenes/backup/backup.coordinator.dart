import 'package:flutter/material.dart';
import 'package:wallet/scenes/backup/backup.view.dart';
import 'package:wallet/scenes/backup/backup.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';

class SetupBackupCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    throw UnimplementedError();
  }

  @override
  ViewBase<ViewModel> start() {
    var viewModel = SetupBackupViewModelImpl(this);
    widget = SetupBackupView(
      viewModel,
    );
    return widget;
  }
}

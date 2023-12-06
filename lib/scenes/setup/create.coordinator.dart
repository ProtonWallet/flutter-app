import 'package:flutter/material.dart';
import 'package:wallet/scenes/backup/backup.coordinator.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/setup/create.view.dart';
import 'package:wallet/scenes/setup/create.viewmodel.dart';

class SetupCreateCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    if (to == ViewIdentifiers.setupBackup) {
      var view = SetupBackupCoordinator().start();
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
    var viewModel = SetupCreateViewModelImpl(this);
    widget = SetupCreateView(
      viewModel,
    );
    return widget;
  }
}

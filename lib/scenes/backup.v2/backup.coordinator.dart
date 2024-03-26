import 'package:flutter/material.dart';
import 'package:wallet/scenes/backup.v2/backup.view.dart';
import 'package:wallet/scenes/backup.v2/backup.viewmodel.dart';
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
  ViewBase<ViewModel> start({Map<String, String> params = const {}}) {
    int walletID = params.containsKey("WalletID") ? int.parse(params["WalletID"]!) : 0;
    var viewModel = SetupBackupViewModelImpl(this, walletID);
    widget = SetupBackupView(
      viewModel,
    );
    return widget;
  }
}

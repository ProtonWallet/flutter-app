import 'package:flutter/material.dart';
import 'package:wallet/components/page_route.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/deletion/deletion.view.dart';
import 'package:wallet/scenes/deletion/deletion.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/setup/ready.coordinator.dart';

class WalletDeletionCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    if (to == ViewIdentifiers.setupReady) {
      var view = SetupReadyCoordinator().start();
      Navigator.push(
          context, CustomPageRoute(page: view, fullscreenDialog: false));
      return view;
    }
    throw UnimplementedError();
  }

  @override
  ViewBase<ViewModel> start({Map<String, String> params = const {}}) {
    int walletID = int.parse(params["WalletID"]!);
    var viewModel = WalletDeletionViewModelImpl(this, walletID);
    widget = WalletDeletionView(
      viewModel,
    );
    return widget;
  }
}

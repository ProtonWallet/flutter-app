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
  ViewBase<ViewModel> start({Map<String, String> params = const {}}) {
    int walletID = params.containsKey("WalletID") ? int.parse(params["WalletID"]!) : 0;
    int accountID = params.containsKey("AccountID") ? int.parse(params["AccountID"]!) : 0;
    var viewModel = ReceiveViewModelImpl(this, walletID, accountID);
    widget = ReceiveView(
      viewModel,
    );
    return widget;
  }
}

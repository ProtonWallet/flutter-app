import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/send/send.view.dart';
import 'package:wallet/scenes/send/send.viewmodel.dart';

class SendCoordinator extends Coordinator {
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
    var viewModel = SendViewModelImpl(this, walletID, accountID);
    widget = SendView(
      viewModel,
    );
    return widget;
  }
}

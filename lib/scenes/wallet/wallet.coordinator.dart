import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/history/history.coordinator.dart';
import 'package:wallet/scenes/wallet/wallet.view.dart';
import 'package:wallet/scenes/wallet/wallet.viewmodel.dart';

import '../receive/receive.coordinator.dart';
import '../send/send.coordinator.dart';

class WalletCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    Map<String, String> map = {
      "WalletID": (widget as WalletView).viewModel.accountModel.walletID.toString(),
      "AccountID": (widget as WalletView).viewModel.accountModel.id.toString(),
    };
    if (to == ViewIdentifiers.send){
      var view = SendCoordinator().start(params: map);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => view,
          fullscreenDialog: true,
          settings: RouteSettings(arguments: map)
      ));
      return view;
    } else if (to == ViewIdentifiers.receive){
      var view = ReceiveCoordinator().start(params: map);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => view,
          fullscreenDialog: true,
          settings: RouteSettings(arguments: map)
      ));
      return view;
    } else if (to == ViewIdentifiers.history){
      var view = HistoryCoordinator().start(params: map);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => view,
          fullscreenDialog: true,
          settings: RouteSettings(arguments: map)
      ));
      return view;
    }
    throw UnimplementedError();
  }

  @override
  ViewBase<ViewModel> start({Map<String, String> params = const {}}) {
    int walletID = int.parse(params["WalletID"]!);
    var viewModel = WalletViewModelImpl(this, walletID);
    widget = WalletView(
      viewModel,
    );
    return widget;
  }
}

import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/debug/websocket.coordinator.dart';
import 'package:wallet/scenes/home.v2/home.view.dart';
import 'package:wallet/scenes/home.v2/home.viewmodel.dart';
import 'package:wallet/scenes/receive/receive.coordinator.dart';
import 'package:wallet/scenes/send/send.coordinator.dart';
import 'package:wallet/scenes/setup/onboard.coordinator.dart';

import '../wallet/wallet.coordinator.dart';

class HomeCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    // Wallet
    if (to == ViewIdentifiers.wallet) {
      Map<String, String> map = {
        "WalletID": (widget as HomeView).viewModel.selectedWalletID.toString()
      };
      var view = WalletCoordinator().start(params: map);

      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => view,
        fullscreenDialog: false,
        settings: RouteSettings(arguments: map)
      ));
      return view;
    }

    // setup
    if (to == ViewIdentifiers.setupOnboard) {
      var view = SetupOnbaordCoordinator().start();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => view,
        fullscreenDialog: true,
      ));
      return view;
    }

    //to send
    if (to == ViewIdentifiers.send) {
      var view = SendCoordinator().start();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => view,
        fullscreenDialog: true,
      ));
      return view;
    }

    //to receive
    if (to == ViewIdentifiers.receive) {
      var view = ReceiveCoordinator().start();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => view,
        fullscreenDialog: true,
      ));
      return view;
    }

    if (to == ViewIdentifiers.testWebsocket) {
      var view = WebSocketCoordinator().start();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => view,
        fullscreenDialog: true,
      ));
      return view;
    }

    throw UnimplementedError();
  }

  @override
  ViewBase<ViewModel> start({Map<String, String> params = const {}}) {
    var viewModel = HomeViewModelImpl(
      this,
    );
    widget = HomeView(
      viewModel,
    );
    return widget;
  }
}

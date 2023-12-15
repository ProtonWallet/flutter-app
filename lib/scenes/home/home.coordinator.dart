import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/debug/websocket.coordinator.dart';
import 'package:wallet/scenes/home/home.view.dart';
import 'package:wallet/scenes/home/home.viewmodel.dart';
import 'package:wallet/scenes/receive/receive.coordinator.dart';
import 'package:wallet/scenes/send/send.coordinator.dart';
import 'package:wallet/scenes/setup/onboard.coordinator.dart';

class HomeCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
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
  ViewBase<ViewModel> start() {
    var viewModel = HomeViewModelImpl(
      this,
    );
    widget = HomeView(
      viewModel,
    );
    return widget;
  }
}

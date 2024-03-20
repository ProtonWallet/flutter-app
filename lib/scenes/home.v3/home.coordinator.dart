import 'package:flutter/material.dart';
import 'package:wallet/scenes/backup.v2/backup.coordinator.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/debug/websocket.coordinator.dart';
import 'package:wallet/scenes/deletion/deletion.coordinator.dart';
import 'package:wallet/scenes/home.v3/home.view.dart';
import 'package:wallet/scenes/home.v3/home.viewmodel.dart';
import 'package:wallet/scenes/receive/receive.coordinator.dart';
import 'package:wallet/scenes/send/send.coordinator.dart';
import 'package:wallet/scenes/settings/mail_integration/maillist.coordinator.dart';
import 'package:wallet/scenes/setup/onboard.coordinator.dart';
import 'package:wallet/scenes/wallet/wallet.coordinator.dart';

class HomeCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    Map<String, String> map = {
      "WalletID": (widget as HomeView).viewModel.currentWallet!.id.toString(),
      "AccountID": (widget as HomeView).viewModel.currentAccount!.id.toString(),
    };

    if (to == ViewIdentifiers.wallet) {
      var view = WalletCoordinator().start(params: map);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => view,
          fullscreenDialog: false,
          settings: RouteSettings(arguments: map)));
      return view;
    } else if (to == ViewIdentifiers.setupOnboard) {
      var view = SetupOnbaordCoordinator().start();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => view,
        fullscreenDialog: true,
      ));
      return view;
    } else if (to == ViewIdentifiers.send) {
      var view = SendCoordinator().start(params: map);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => view,
        fullscreenDialog: true,
      ));
      return view;
    } else if (to == ViewIdentifiers.setupBackup) {
      var view = SetupBackupCoordinator().start(params: map);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => view,
        fullscreenDialog: true,
      ));
      return view;
    } else if (to == ViewIdentifiers.receive) {
      var view = ReceiveCoordinator().start(params: map);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => view,
        fullscreenDialog: true,
      ));
      return view;
    } else if (to == ViewIdentifiers.testWebsocket) {
      var view = WebSocketCoordinator().start();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => view,
        fullscreenDialog: true,
      ));
      return view;
    } else if (to == ViewIdentifiers.mailList) {
      var view = MailListCoordinator().start();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => view,
        fullscreenDialog: true,
      ));
      return view;
    } else if (to == ViewIdentifiers.walletDeletion) {
      var view = WalletDeletionCoordinator().start(params: map);
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => view,
          fullscreenDialog: true,
          settings: RouteSettings(arguments: map)));
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

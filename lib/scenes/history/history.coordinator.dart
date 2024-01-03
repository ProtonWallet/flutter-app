import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/history/details.coordinator.dart';
import 'package:wallet/scenes/history/history.view.dart';
import 'package:wallet/scenes/history/history.viewmodel.dart';

class HistoryCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    if (to == ViewIdentifiers.historyDetails) {
      var view = HistoryDetailCoordinator().start();
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => view));
      return view;
    }

    throw UnimplementedError();
  }

  @override
  ViewBase<ViewModel> start({Map<String, String> params = const {}}) {
    int walletID = params.containsKey("WalletID") ? int.parse(params["WalletID"]!) : 0;
    int accountID = params.containsKey("AccountID") ? int.parse(params["AccountID"]!) : 0;
    var viewModel = HistoryViewModelImpl(this, walletID, accountID
    );
    widget = HistoryView(
      viewModel,
    );
    return widget;
  }
}

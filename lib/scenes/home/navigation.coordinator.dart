import 'package:flutter/material.dart';
import 'package:wallet/scenes/buy/buybitcoin.coordinator.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/history/history.coordinator.dart';
import 'package:wallet/scenes/home.v3/home.coordinator.dart';
import 'package:wallet/scenes/home/navigation.view.dart';
import 'package:wallet/scenes/home/navigation.viewmodel.dart';
import 'package:wallet/scenes/settings/settings.coordinator.dart';
import 'package:wallet/scenes/transfer/transfer.coordinator.dart';

class HomeNavigationCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    throw UnimplementedError();
  }

  @override
  ViewBase<ViewModel> start({Map<String, String> params = const {}}) {
    var viewModel = HomeNavigationViewModelImpl(
      this,
    );
    widget = HomeNavigationView(
      viewModel,
    );
    return widget;
  }

  @override
  List<ViewBase<ViewModel>> starts() {
    return [
      HomeCoordinator().start(),
      // HistoryCoordinator().start(),
      // BuyBitcoinCoordinator().start(),
      // TransferCoordinator().start(),
      // SettingsCoordinator().start()
    ];
  }
}

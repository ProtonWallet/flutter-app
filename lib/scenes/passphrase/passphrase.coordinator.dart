import 'package:flutter/material.dart';
import 'package:wallet/scenes/passphrase/passphrase.view.dart';
import 'package:wallet/scenes/passphrase/passphrase.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';

import '../../components/page_route.dart';
import '../core/view.navigatior.identifiers.dart';
import '../setup/ready.coordinator.dart';

class SetupPassPhraseCoordinator extends Coordinator {
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
    String? strMnemonic = params.containsKey("Mnemonic") ? params["Mnemonic"] : "";
    var viewModel = SetupPassPhraseViewModelImpl(this, strMnemonic!);
    widget = SetupPassPhraseView(
      viewModel,
    );
    return widget;
  }
}

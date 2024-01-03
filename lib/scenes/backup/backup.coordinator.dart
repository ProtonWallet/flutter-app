import 'package:flutter/material.dart';
import 'package:wallet/scenes/backup/backup.view.dart';
import 'package:wallet/scenes/backup/backup.viewmodel.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/passphrase/passphrase.coordinator.dart';

import '../../components/page_route.dart';
import '../core/view.navigatior.identifiers.dart';

class SetupBackupCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    if (to == ViewIdentifiers.passphrase) {
      Map<String, String> params = {
        "Mnemonic": (widget as SetupBackupView).viewModel.strMnemonic
      };
      var view = SetupPassPhraseCoordinator().start(params: params);
      Navigator.push(
          context, CustomPageRoute(page: view, fullscreenDialog: false));
      return view;
    }
    throw UnimplementedError();
  }

  @override
  ViewBase<ViewModel> start({Map<String, String> params = const {}}) {
    String? strMnemonic =
        params.containsKey("Mnemonic") ? params["Mnemonic"] : "";
    var viewModel = SetupBackupViewModelImpl(this, strMnemonic!);
    widget = SetupBackupView(
      viewModel,
    );
    return widget;
  }
}

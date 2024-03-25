import 'package:flutter/material.dart';
import 'package:wallet/components/page_route.dart';
import 'package:wallet/scenes/backup/backup.coordinator.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/passphrase/passphrase.coordinator.dart';
import 'package:wallet/scenes/setup/create.view.dart';
import 'package:wallet/scenes/setup/create.viewmodel.dart';

class SetupCreateCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    if (to == ViewIdentifiers.passphrase) {
      Map<String, String> params = {
        "Mnemonic": (widget as SetupCreateView).viewModel.strMnemonic
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
    var viewModel = SetupCreateViewModelImpl(this);
    widget = SetupCreateView(
      viewModel,
    );
    return widget;
  }
}

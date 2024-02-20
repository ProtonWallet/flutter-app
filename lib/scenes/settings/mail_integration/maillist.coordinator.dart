import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/settings/mail_integration/maillist.view.dart';
import 'package:wallet/scenes/settings/mail_integration/maillist.viewmodel.dart';

import 'mailedit.coordinator.dart';

class MailListCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    if (to == ViewIdentifiers.mailEdit) {
      Map<String, String> params = {
        "mailSettingID":
            (widget as MailListView).viewModel.mailSettingID.toString()
      };
      var view = MailEditCoordinator().start(params: params);
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
    var viewModel = MailListViewModelImpl(this);
    widget = MailListView(
      viewModel,
    );
    return widget;
  }
}

import 'package:flutter/material.dart';
import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/core/view.navigator.dart';
import 'package:wallet/scenes/settings/mail_integration/mailedit.view.dart';
import 'package:wallet/scenes/settings/mail_integration/mailedit.viewmodel.dart';

class MailEditCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  @override
  ViewBase<ViewModel> move(NavigationIdentifier to, BuildContext context) {
    throw UnimplementedError();
  }

  @override
  ViewBase<ViewModel> start({Map<String, String> params = const {}}) {
    int mailSettingID = params.containsKey("mailSettingID") ? int.parse(params["mailSettingID"]!) : 0;
    var viewModel = MailEditViewModelImpl(this, mailSettingID);
    widget = MailEditView(
      viewModel,
    );
    return widget;
  }
}

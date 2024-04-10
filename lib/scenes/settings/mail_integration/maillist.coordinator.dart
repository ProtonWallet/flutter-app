import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/settings/mail_integration/maillist.view.dart';
import 'package:wallet/scenes/settings/mail_integration/maillist.viewmodel.dart';

import 'mailedit.coordinator.dart';

class MailListCoordinator extends Coordinator {
  late ViewBase widget;

  @override
  void end() {}

  void showMailEdit(int mailSettingID) {
    var view = MailEditCoordinator(mailSettingID).start();
    push(view, fullscreenDialog: true);
  }

  @override
  ViewBase<ViewModel> start() {
    var viewModel = MailListViewModelImpl(this);
    widget = MailListView(
      viewModel,
    );
    return widget;
  }
}

import 'package:wallet/scenes/core/coordinator.dart';
import 'package:wallet/scenes/core/view.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/settings/mail_integration/mailedit.view.dart';
import 'package:wallet/scenes/settings/mail_integration/mailedit.viewmodel.dart';

class MailEditCoordinator extends Coordinator {
  late ViewBase widget;
  final int mailSettingID;

  MailEditCoordinator(this.mailSettingID);

  @override
  void end() {}

  @override
  ViewBase<ViewModel> start() {
    var viewModel = MailEditViewModelImpl(this, mailSettingID);
    widget = MailEditView(
      viewModel,
    );
    return widget;
  }
}

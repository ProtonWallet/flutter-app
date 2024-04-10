import 'dart:async';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/settings/mail_integration/maillist.coordinator.dart';

abstract class MailListViewModel extends ViewModel<MailListCoordinator> {
  MailListViewModel(super.coordinator);
  int mailSettingID = 0;
}

class MailListViewModelImpl extends MailListViewModel {
  MailListViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<MailListViewModel>.broadcast();
  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {}

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void move(NavigationIdentifier to) {
    switch (to) {
      case ViewIdentifiers.mailEdit:
        coordinator.showMailEdit(mailSettingID);
    }
  }
}

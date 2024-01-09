import 'dart:async';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class MailListViewModel extends ViewModel {
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
}

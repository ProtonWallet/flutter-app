import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wallet/scenes/core/viewmodel.dart';

import '../../constants/constants.dart';

abstract class NewUserViewModel extends ViewModel {
  NewUserViewModel(super.coordinator);

  bool isLastPage = false;

  void updateLastPageStatus(bool lastPage);

  void done();

  void goHome();
}

class NewUserViewModelImpl extends NewUserViewModel {
  NewUserViewModelImpl(super.coordinator);

  final datasourceChangedStreamController =
      StreamController<NewUserViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    return;
  }

  @override
  void goHome() {
    // coordinator.move(to, context);
  }

  @override
  void updateLastPageStatus(bool lastPage) {
    isLastPage = lastPage;
    datasourceChangedStreamController.sink.add(this);
  }

  @override
  Future<void> done() async {
    SharedPreferences _preferences = await SharedPreferences.getInstance();
    _preferences.setBool(spHasShowNewUserPage, true);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;
}

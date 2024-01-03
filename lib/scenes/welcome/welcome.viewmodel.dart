import 'dart:async';

import 'package:flutter/src/widgets/framework.dart';
import 'package:path/path.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

import '../../helper/local_auth.dart';
import '../core/view.navigatior.identifiers.dart';

abstract class WelcomeViewModel extends ViewModel {
  WelcomeViewModel(super.coordinator);

  void localLogin(BuildContext context);

  void goHome();
}

class WelcomeViewModelImpl extends WelcomeViewModel {
  WelcomeViewModelImpl(super.coordinator);

  final datasourceChangedStreamController =
      StreamController<WelcomeViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  void localLogin(BuildContext context) {
    LocalAuth.authenticate("Please authenticate to login").then((auth) => {
          if (auth) {coordinator.move(ViewIdentifiers.home, context)}
        });
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
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;
}

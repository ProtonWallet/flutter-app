import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wallet/helper/local_auth.dart';
import 'package:wallet/helper/secure_storage_helper.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';
import 'package:wallet/scenes/welcome/welcome.coordinator.dart';
import 'package:wallet/scenes/welcome/welcome.view.dart';

abstract class WelcomeViewModel extends ViewModel {
  WelcomeViewModel(super.coordinator);

  void localLogin(BuildContext context);

  void goHome();
}

class WelcomeViewModelImpl extends WelcomeViewModel {
  WelcomeViewModelImpl(super.coordinator);

  bool hadLocallogin = false;
  final datasourceChangedStreamController =
      StreamController<WelcomeViewModel>.broadcast();

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> localLogin(BuildContext context) async {
    if (!hadLocallogin) {
      hadLocallogin = true;
      if (await SecureStorageHelper.get("sessionId") != "") {
        LocalAuth.authenticate("Authenticate to login").then((auth) {
          if (auth) {
            ((coordinator as WelcomeCoordinator).widget as WelcomeView)
                .loginResume();
            coordinator.move(ViewIdentifiers.home, context);
          }
        });
      }
    }
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

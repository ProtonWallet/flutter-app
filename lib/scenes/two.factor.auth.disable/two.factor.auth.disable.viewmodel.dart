import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class TwoFactorAuthDisableViewModel extends ViewModel {
  TwoFactorAuthDisableViewModel(super.coordinator);
  List<TextEditingController> digitControllers = [];
  late TextEditingController passwordController;
  Future<bool> disable2FA();
}

class TwoFactorAuthDisableViewModelImpl extends TwoFactorAuthDisableViewModel {
  TwoFactorAuthDisableViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<TwoFactorAuthDisableViewModel>.broadcast();

  @override
  Future<bool> disable2FA() async {
    // String totp = "";
    // for (TextEditingController textEditingController in digitControllers) {
    //   totp += textEditingController.text;
    // }
    try {
      // TODO:: enable 2fa
      // int result = await proton_api.disable2FaTotp(
      //     username: "ProtonWallet",
      //     password: passwordController.text,
      //     twoFactorCode: totp);
      int result = 0;
      return result == 0; // disabled
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  Future<void> loadData() async {
    digitControllers = List.generate(6, (index) => TextEditingController());
    passwordController = TextEditingController();
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void move(NavID to) {}
}

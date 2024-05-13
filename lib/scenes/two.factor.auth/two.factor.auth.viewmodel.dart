import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/two_factor_auth_helper.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class TwoFactorAuthViewModel extends ViewModel {
  TwoFactorAuthViewModel(super.coordinator);
  int page = 0;
  String otpAuthString = "";
  String secret = "";
  List<String> backupPhrases = [];
  List<TextEditingController> digitControllers = [];
  late TextEditingController passwordController;
  void updatePage(int newPage);
  Future<bool> setup2FA();
}

class TwoFactorAuthViewModelImpl extends TwoFactorAuthViewModel {
  TwoFactorAuthViewModelImpl(super.coordinator);
  final datasourceChangedStreamController =
      StreamController<TwoFactorAuthViewModel>.broadcast();

  @override
  Future<bool> setup2FA() async {
    // String totp = "";
    // for (TextEditingController textEditingController in digitControllers) {
    //   totp += textEditingController.text;
    // }
    try {
      // TODO:: enable 2fa
      // backupPhrases = await proton_api.set2FaTotp(
      //     username: "ProtonWallet",
      //     password: passwordController.text,
      //     totpSharedSecret: secret,
      //     totpConfirmation: totp);
      backupPhrases = ["1111", "2222", "3333"];
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    datasourceChangedStreamController.close();
  }

  @override
  void updatePage(int newPage) {
    page = newPage;
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Future<void> loadData() async {
    digitControllers = List.generate(6, (index) => TextEditingController());
    passwordController = TextEditingController();
    secret = TwoFactorAuthHelper.generateSecret();
    otpAuthString =
        "otpauth://totp/ProtonWallet@proton.black?secret=$secret&issuer=Proton&algorithm=SHA1&digits=6&period=30";
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  void move(NavID to) {}
}

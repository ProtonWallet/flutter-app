import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/two_factor_auth_helper.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/rust/api/api_service/proton_settings_client.dart';
import 'package:wallet/rust/api/api_service/proton_users_client.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/api/proton_wallet/srp/srp_client.dart';
import 'package:wallet/rust/proton_api/proton_users.dart';
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
  late FocusNode passphraseFocusNode;

  void updatePage(int newPage);

  Future<bool> setup2FA();

  bool isLoading = false;

  String error = "";
}

class TwoFactorAuthViewModelImpl extends TwoFactorAuthViewModel {
  TwoFactorAuthViewModelImpl(
    super.coordinator,
    this.userManager,
    this.protonUsersApi,
    this.protonSettingsApi,
    this.userDataProvider,
  );

  final UserManager userManager;
  final ProtonUsersClient protonUsersApi;
  final ProtonSettingsClient protonSettingsApi;

  // final
  final UserDataProvider userDataProvider;

  @override
  Future<bool> setup2FA() async {
    error = "";
    String loginTwoFaTotp = "";
    final String loginPassword = passwordController.text;
    for (TextEditingController textEditingController in digitControllers) {
      loginTwoFaTotp += textEditingController.text;
    }

    // TODO(move): move this to rust
    try {
      final authInfo = await protonUsersApi.getAuthInfo(intent: "Proton");

      final clientProofs = await FrbSrpClient.generateProofs(
          loginPassword: loginPassword,
          version: authInfo.version,
          salt: authInfo.salt,
          modulus: authInfo.modulus,
          serverEphemeral: authInfo.serverEphemeral);

      final proofs = ProtonSrpClientProofs(
          clientEphemeral: clientProofs.clientEphemeral,
          clientProof: clientProofs.clientProof,
          srpSession: authInfo.srpSession);

      final serverProofs = await protonUsersApi.unlockPasswordChange(
        proofs: proofs,
      );

      /// check if the server proofs are valid
      final check = clientProofs.expectedServerProof == serverProofs;
      logger.i("enable2FaTotp password server proofs: $check");
      if (!check) {
        logger.e('Invalid server proofs');
      }
      final req = SetTwoFaTOTPRequestBody(
        totpConfirmation: loginTwoFaTotp,
        totpSharedSecret: secret,
      );
      final response = await protonSettingsApi.enable2FaTotp(req: req);
      logger.i("enable2FaTotp response code: $response");
      // final lockCode = await protonUsersApi.lockSensitiveSettings();
      // logger.i("enable2FaTotp lockSensitiveSettings: $lockCode");
      backupPhrases = response.twoFactorRecoveryCodes;
      userDataProvider.enabled2FA(response.code == 1000);
      return true;
    } on BridgeError catch (exception, stracktrace) {
      error = parseSampleDisplayError(exception);
      Sentry.captureException(exception, stackTrace: stracktrace);
      logger.e(exception.toString());
      return false;
    } catch (e) {
      error = e.toString();
      logger.e(e.toString());
      return false;
    }
  }

  @override
  void updatePage(int newPage) {
    page = newPage;
    sinkAddSafe();
  }

  @override
  Future<void> loadData() async {
    digitControllers = List.generate(6, (index) => TextEditingController());
    passwordController = TextEditingController();
    passphraseFocusNode = FocusNode();
    secret = TwoFactorAuthHelper.generateSecret();
    final userEmail = userManager.userInfo.userMail;
    otpAuthString =
        "otpauth://totp/$userEmail?secret=$secret&issuer=Proton&algorithm=SHA1&digits=6&period=30";
    sinkAddSafe();
  }

  @override
  Future<void> move(NavID to) async {}
}

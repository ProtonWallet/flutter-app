import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/rust/api/api_service/proton_settings_client.dart';
import 'package:wallet/rust/api/api_service/proton_users_client.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/api/proton_wallet/srp/srp_client.dart';
import 'package:wallet/rust/proton_api/proton_users.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

abstract class TwoFactorAuthDisableViewModel extends ViewModel {
  TwoFactorAuthDisableViewModel(super.coordinator);
  List<TextEditingController> digitControllers = [];
  late TextEditingController passwordController;
  late FocusNode passphraseFocusNode;
  Future<bool> disable2FA();
  String error = "";
}

class TwoFactorAuthDisableViewModelImpl extends TwoFactorAuthDisableViewModel {
  TwoFactorAuthDisableViewModelImpl(
    super.coordinator,
    this.protonUsersApi,
    this.protonSettingsApi,
    this.userDataProvider,
  );

  final ProtonUsersClient protonUsersApi;
  final ProtonSettingsClient protonSettingsApi;
  final UserDataProvider userDataProvider;

  @override
  Future<bool> disable2FA() async {
    error = "";
    String loginTwoFaTotp = "";
    final String loginPassword = passwordController.text;
    for (TextEditingController textEditingController in digitControllers) {
      loginTwoFaTotp += textEditingController.text;
    }

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
        srpSession: authInfo.srpSession,
        twoFactorCode: loginTwoFaTotp,
      );
      final response = await protonSettingsApi.disable2FaTotp(req: proofs);
      logger.i("disable2FaTotp response code: $response");
      userDataProvider.enabled2FA(false);
      return true;
    } on BridgeError catch (exception, stacktrace) {
      error = parseMuonError(exception) ?? parseSampleDisplayError(exception);
      Sentry.captureException(exception, stackTrace: stacktrace);
      logger.e(exception.toString());
      return false;
    } catch (e) {
      logger.e(e.toString());
      return false;
    }
  }

  @override
  Future<void> loadData() async {
    digitControllers = List.generate(6, (index) => TextEditingController());
    passwordController = TextEditingController();
    passphraseFocusNode = FocusNode();
  }

  @override
  Future<void> move(NavID to) async {}
}

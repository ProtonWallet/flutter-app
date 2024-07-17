import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/extension/stream.controller.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/two_factor_auth_helper.dart';
import 'package:wallet/managers/providers/proton.user.data.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/rust/api/api_service/proton_settings_client.dart';
import 'package:wallet/rust/api/api_service/proton_users_client.dart';
import 'package:wallet/rust/api/srp/srp_client.dart';
import 'package:wallet/rust/common/errors.dart';
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
    this.protonUserData,
  );
  final datasourceChangedStreamController =
      StreamController<TwoFactorAuthViewModel>.broadcast();

  final UserManager userManager;
  final ProtonUsersClient protonUsersApi;
  final ProtonSettingsClient protonSettingsApi;
  // final
  final ProtonUserDataProvider protonUserData;

  @override
  Future<bool> setup2FA() async {
    error = "";
    String loginTwoFaTotp = "";
    final String loginPassword = passwordController.text;
    for (TextEditingController textEditingController in digitControllers) {
      loginTwoFaTotp += textEditingController.text;
    }
    try {
      final authInfo = await protonUsersApi.getAuthInfo(intent: "Proton");

      final clientProofs = await SrpClient.generateProofs(
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
      final lockCode = await protonUsersApi.lockSensitiveSettings();
      logger.i("enable2FaTotp lockSensitiveSettings: $lockCode");
      backupPhrases = response.twoFactorRecoveryCodes;
      protonUserData.enabled2FA(response.code == 1000);
      return true;
    } on BridgeError catch (exception) {
      error = parseSampleDisplayError(exception);
      logger.e(exception.toString());
      return false;
    } catch (e) {
      logger.e(e.toString());
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
    final userEmail = userManager.userInfo.userMail;
    otpAuthString =
        "otpauth://totp/$userEmail?secret=$secret&issuer=Proton&algorithm=SHA1&digits=6&period=30";
    datasourceChangedStreamController.sinkAddSafe(this);
  }

  @override
  Stream<ViewModel> get datasourceChanged =>
      datasourceChangedStreamController.stream;

  @override
  Future<void> move(NavID to) async {}
}

         

        //   final loginPassword = event.password;
        //   final loginTwoFa = event.twofa;
        //   final authInfo = state.authInfo ??
        //       await protonUsersApi.getAuthInfo(intent: "Proton");

        //   /// build srp client proof
        //   final clientProofs = await SrpClient.generateProofs(
        //       loginPassword: loginPassword,
        //       version: authInfo.version,
        //       salt: authInfo.salt,
        //       modulus: authInfo.modulus,
        //       serverEphemeral: authInfo.serverEphemeral);

        //   /// password scop unlock password change  ---  add 2fa code if needed
        //   final proofs = authInfo.twoFa.enabled == 1
        //       ? ProtonSrpClientProofs(
        //           clientEphemeral: clientProofs.clientEphemeral,
        //           clientProof: clientProofs.clientProof,
        //           srpSession: authInfo.srpSession,
        //           twoFactorCode: loginTwoFa)
        //       : ProtonSrpClientProofs(
        //           clientEphemeral: clientProofs.clientEphemeral,
        //           clientProof: clientProofs.clientProof,
        //           srpSession: authInfo.srpSession);

        //   try {
        //     final serverProofs = await protonUsersApi.unlockPasswordChange(
        //       proofs: proofs,
        //     );

        //     /// check if the server proofs are valid
        //     final check = clientProofs.expectedServerProof == serverProofs;
        //     logger.i("EnableRecovery password server proofs: $check");
        //     if (!check) {
        //       return Future.error('Invalid server proofs');
        //     }

        //     /// generate new entropy and mnemonic
        //     final salt = WalletKeyHelper.getRandomValues(16);
        //     final randomEntropy = WalletKeyHelper.getRandomValues(16);

        //     final FrbMnemonic mnemonic =
        //         FrbMnemonic.newWith(entropy: randomEntropy);
        //     final mnemonicWords = mnemonic.asWords();
        //     logger.d("Recovery Mnemonic: $mnemonicWords");
        //     final recoveryPassword = randomEntropy.base64encode();

        //     final hashedPassword = await SrpClient.computeKeyPassword(
        //       password: recoveryPassword,
        //       salt: salt,
        //     );

        //     final userFirstKey = await userManager.getFirstKey();
        //     final userKeys = userInfo.keys;
        //     if (userKeys == null) {
        //       return Future.error('User keys not found');
        //     }
        //     if (userKeys.length != 1) {
        //       return Future.error('More then one key is not supported yet');
        //     }

        //     final oldPassphrase = userFirstKey.passphrase;

        //     final List<MnemonicUserKey> mnUserKeys = [];

        //     /// reencrypt password for now only support one
        //     for (ProtonUserKey key in userKeys) {
        //       final newKey = proton_crypto.changePrivateKeyPassword(
        //         key.privateKey,
        //         oldPassphrase,
        //         hashedPassword,
        //       );
        //       mnUserKeys.add(MnemonicUserKey(id: key.id, privateKey: newKey));
        //     }

        //     /// get srp module
        //     final serverModule = await protonUsersApi.getAuthModule();

        //     /// get clear text and verify signature
        //     final SRPVerifierB64 verifier = await SrpClient.generateVerifer(
        //       password: recoveryPassword,
        //       serverModulus: serverModule.modulus,
        //     );

        //     final auth = MnemonicAuth(
        //       modulusId: serverModule.modulusId,
        //       salt: verifier.salt,
        //       version: verifier.version,
        //       verifier: verifier.verifier,
        //     );

        //     final req = UpdateMnemonicSettingsRequestBody(
        //       mnemonicUserKeys: mnUserKeys,
        //       mnemonicSalt: salt.base64encode(),
        //       mnemonicAuth: auth,
        //     );
        //     final recoveryCode =
        //         await protonSettingsApi.setMnemonicSettings(req: req);
        //     logger.i("EnableRecovery response code: $recoveryCode");
        //     final lockCode = await protonUsersApi.lockSensitiveSettings();
        //     if (recoveryCode != 1000) {
        //       emit(state.copyWith(
        //         isLoading: false,
        //         requireAuthModel: const RequireAuthModel(),
        //         error:
        //             "Eanble recovery failed, please try again. code: $recoveryCode",
        //       ));
        //       return;
        //     }
        //     logger.i("EnableRecovery lockSensitiveSettings: $lockCode");
        //     if (lockCode != 1000) {
        //       emit(state.copyWith(
        //         isLoading: false,
        //         requireAuthModel: const RequireAuthModel(),
        //         error:
        //             "Eanble recovery failed, please try again. code: $lockCode",
        //       ));
        //       return;
        //     }
        //     userDataProvider.enabledRecovery(true);
        //     emit(state.copyWith(
        //         isLoading: false,
        //         error: "",
        //         isRecoveryEnabled: true,
        //         requireAuthModel: const RequireAuthModel(),
        //         mnemonic: mnemonicWords.join(" ")));
        //   } on BridgeError catch (e) {
        //     final errorMessage = parseSampleDisplayError(e);
        //     emit(state.copyWith(
        //         isLoading: false,
        //         requireAuthModel: const RequireAuthModel(),
        //         error: errorMessage));
        //   } catch (e) {
        //     emit(state.copyWith(
        //         isLoading: false,
        //         requireAuthModel: const RequireAuthModel(),
        //         error: e.toString()));
        //   }
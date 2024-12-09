import 'dart:async';
import 'package:collection/collection.dart';
import 'package:flutter_tags_x/flutter_tags_x.dart';
import 'package:sentry/sentry.dart';
import 'package:wallet/helper/dbhelper.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/extension/data.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/managers/providers/wallet.mnemonic.provider.dart';
import 'package:wallet/managers/providers/wallet.name.provider.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/api_service/proton_users_client.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/api/proton_wallet/srp/srp_client.dart';
import 'package:wallet/rust/proton_api/proton_users.dart';
import 'package:wallet/scenes/backup.seed/backup.coordinator.dart';
import 'package:wallet/scenes/core/view.navigatior.identifiers.dart';
import 'package:wallet/scenes/core/viewmodel.dart';

/// UnlockPasswordState
enum SetupBackupState {
  start,
  auth,
  authShown,
  done,
}

abstract class SetupBackupViewModel extends ViewModel<SetupBackupCoordinator> {
  SetupBackupViewModel(
    super.coordinator,
    this.walletID,
  );

  final String walletID;
  List<Item> itemList = [];
  String strMnemonic = "";
  bool inIntroduce = true;
  SetupBackupState flowState = SetupBackupState.start;
  int twofaStatus = 0;
  String error = "";
  String walletName = "";

  Future<void> viewSeed(String loginPassword, String twofa);

  void setBackup();

  Future<void> tryLoadMnemonic();

  void reset();

  void setIntroduce({required bool introduce});
}

class SetupBackupViewModelImpl extends SetupBackupViewModel {
  final WalletsDataProvider walletsDataProvider;
  final UserDataProvider userDataProvider;
  final ProtonUsersClient protonUsersApi;
  final WalletNameProvider walletNameService;
  final WalletMnemonicProvider walletMnemonicService;

  final String userID;
  final bool needPassword;
  GetAuthInfoResponseBody? authInfo;

  SetupBackupViewModelImpl(
    super.coordinator,
    super.walletID,
    this.walletsDataProvider,
    this.userDataProvider,
    this.walletNameService,
    this.walletMnemonicService,
    this.userID,
    this.protonUsersApi, {
    required this.needPassword,
  });

  @override
  Future<void> loadData() async {}

  @override
  Future<void> viewSeed(String loginPassword, String twofa) async {
    try {
      final authInfo =
          this.authInfo ?? await protonUsersApi.getAuthInfo(intent: "Proton");

      /// build srp client proof
      final clientProofs = await FrbSrpClient.generateProofs(
          loginPassword: loginPassword,
          version: authInfo.version,
          salt: authInfo.salt,
          modulus: authInfo.modulus,
          serverEphemeral: authInfo.serverEphemeral);

      /// password scop unlock password change  ---  add 2fa code if needed
      final proofs = authInfo.twoFa.enabled != 0
          ? ProtonSrpClientProofs(
              clientEphemeral: clientProofs.clientEphemeral,
              clientProof: clientProofs.clientProof,
              srpSession: authInfo.srpSession,
              twoFactorCode: twofa)
          : ProtonSrpClientProofs(
              clientEphemeral: clientProofs.clientEphemeral,
              clientProof: clientProofs.clientProof,
              srpSession: authInfo.srpSession);

      final serverProofs = await protonUsersApi.unlockPasswordChange(
        proofs: proofs,
      );

      strMnemonic = await walletMnemonicService.getMnemonicWithID(walletID);
      strMnemonic.split(" ").forEachIndexed((index, element) {
        itemList.add(Item(
          title: element,
          index: index,
        ));
      });

      try {
        walletName = await walletNameService.getNameWithID(walletID);
      } catch (e, stacktrace) {
        walletName = "Unknown";
        logger.e("viewSeed BridgeError: $e, stacktrace: $stacktrace");
      }

      /// check if the server proofs are valid
      final check = clientProofs.expectedServerProof == serverProofs;
      logger.i("ViewSeed password server proofs: $check");
      if (!check) {
        throw Exception("Invalid server proofs");
      }
      flowState = SetupBackupState.done;
    } on BridgeError catch (e, stacktrace) {
      error = parseSampleDisplayError(e);
      logger.e("viewSeed BridgeError: $e, stacktrace: $stacktrace");
      Sentry.captureException(e, stackTrace: stacktrace);
      reset();
    } catch (e, stacktrace) {
      logger.e("viewSeed error: $e, stacktrace: $stacktrace");
      error = e.toString();
    }
    sinkAddSafe();
  }

  @override
  Future<void> reset() async {
    flowState = SetupBackupState.start;
    twofaStatus = 0;
    sinkAddSafe();
  }

  @override
  Future<void> setBackup() async {
    final WalletModel walletModel =
        await DBHelper.walletDao!.findByServerID(walletID);
    walletModel.showWalletRecovery = 0;
    walletsDataProvider.disableShowWalletRecovery(walletModel.walletID);
    walletsDataProvider.insertOrUpdateWallet(
      userID: userID,
      name: walletModel.name,
      encryptedMnemonic: "",
      passphrase: walletModel.passphrase,
      imported: walletModel.imported,
      priority: walletModel.priority,
      status: walletModel.status,
      type: walletModel.type,
      walletID: walletModel.walletID,
      publickey: walletModel.publicKey.base64encode(),
      fingerprint: walletModel.fingerprint ?? "",
      showWalletRecovery: walletModel.showWalletRecovery,
      migrationRequired: walletModel.migrationRequired,
      legacy: walletModel.legacy,
    );
    userDataProvider.enabledShowWalletRecovery(false);
  }

  @override
  Future<void> tryLoadMnemonic() async {
    if (flowState == SetupBackupState.start) {
      final authInfo = await protonUsersApi.getAuthInfo(intent: "Proton");

      /// 0 for disabled, 1 for OTP, 2 for FIDO2, 3 for both
      twofaStatus = authInfo.twoFa.enabled;
      flowState = SetupBackupState.auth;
      sinkAddSafe();
    }
  }

  @override
  Future<void> move(NavID to) async {}

  @override
  void setIntroduce({required bool introduce}) {
    inIntroduce = introduce;
    sinkAddSafe();
  }
}

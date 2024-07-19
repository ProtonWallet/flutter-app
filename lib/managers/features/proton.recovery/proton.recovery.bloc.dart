import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/extension/data.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/helper/walletkey_helper.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.event.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.state.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/rust/api/api_service/proton_settings_client.dart';
import 'package:wallet/rust/api/api_service/proton_users_client.dart';
import 'package:wallet/rust/api/bdk_wallet/mnemonic.dart';
import 'package:wallet/rust/api/srp/srp_client.dart';
import 'package:wallet/rust/common/errors.dart';
import 'package:wallet/rust/proton_api/proton_users.dart';
import 'package:wallet/rust/srp/proofs.dart';

/// Define the Bloc
class ProtonRecoveryBloc
    extends Bloc<ProtonRecoveryEvent, ProtonRecoveryState> {
  final UserManager userManager;
  final ProtonUsersClient protonUsersApi;
  final ProtonSettingsClient protonSettingsApi;
  final UserDataProvider userDataProvider;

  /// initialize the bloc with the initial state
  ProtonRecoveryBloc(
    this.userManager,
    this.protonUsersApi,
    this.userDataProvider,
    this.protonSettingsApi,
  ) : super(const ProtonRecoveryState()) {
    on<LoadingRecovery>((event, emit) async {
      emit(state.copyWith(
          isLoading: true,
          error: "",
          isRecoveryEnabled: false,
          mnemonic: "",
          requireAuthModel: const RequireAuthModel()));

      final userInfo = await protonUsersApi.getUserInfo();
      final status = userInfo.mnemonicStatus == 3;

      emit(state.copyWith(isLoading: false, isRecoveryEnabled: status));
    });

    on<TestRecovery>((event, emit) async {
      emit(state.copyWith(
          isLoading: true,
          error: "",
          isRecoveryEnabled: false,
          mnemonic:
              "banner tag desk cart mirror horse name minimum hen sport sadness evidence",
          requireAuthModel: const RequireAuthModel()));

      final userInfo = await protonUsersApi.getUserInfo();
      final status = userInfo.mnemonicStatus == 3;

      emit(state.copyWith(isLoading: false, isRecoveryEnabled: status));
    });

    on<EnableRecovery>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: ""));
      // get user info
      final userInfo = await protonUsersApi.getUserInfo();
      final status = userInfo.mnemonicStatus;
      // 0 - Mnemonic is disabled
      // 1 - Mnemonic is enabled but not set
      // 2 - Mnemonic is enabled but needs to be re-activated
      // 3 - Mnemonic is enabled and set
      if (status == 0 || status == 1) {
        /// set new flow
        /// get auth info

        if (event.step == RecoverySteps.start) {
          // var status = userInfo.mnemonicStatus;
          // check if the status is disabled already skip the process
          /// get auth info
          final authInfo = await protonUsersApi.getAuthInfo(intent: "Proton");

          /// 0 for disabled, 1 for OTP, 2 for FIDO2, 3 for both
          final twoFaEnable = authInfo.twoFa.enabled;
          final authSetp =
              RequireAuthModel(requireAuth: true, twofaStatus: twoFaEnable);
          emit(state.copyWith(requireAuthModel: authSetp, authInfo: authInfo));
        } else if (event.step == RecoverySteps.auth) {
          final loginPassword = event.password;
          final loginTwoFa = event.twofa;
          final authInfo = state.authInfo ??
              await protonUsersApi.getAuthInfo(intent: "Proton");

          /// build srp client proof
          final clientProofs = await SrpClient.generateProofs(
              loginPassword: loginPassword,
              version: authInfo.version,
              salt: authInfo.salt,
              modulus: authInfo.modulus,
              serverEphemeral: authInfo.serverEphemeral);

          /// password scop unlock password change  ---  add 2fa code if needed
          final proofs = authInfo.twoFa.enabled == 1
              ? ProtonSrpClientProofs(
                  clientEphemeral: clientProofs.clientEphemeral,
                  clientProof: clientProofs.clientProof,
                  srpSession: authInfo.srpSession,
                  twoFactorCode: loginTwoFa)
              : ProtonSrpClientProofs(
                  clientEphemeral: clientProofs.clientEphemeral,
                  clientProof: clientProofs.clientProof,
                  srpSession: authInfo.srpSession);

          try {
            final serverProofs = await protonUsersApi.unlockPasswordChange(
              proofs: proofs,
            );

            /// check if the server proofs are valid
            final check = clientProofs.expectedServerProof == serverProofs;
            logger.i("EnableRecovery password server proofs: $check");
            if (!check) {
              return Future.error('Invalid server proofs');
            }

            /// generate new entropy and mnemonic
            final salt = WalletKeyHelper.getRandomValues(16);
            final randomEntropy = WalletKeyHelper.getRandomValues(16);

            final FrbMnemonic mnemonic =
                FrbMnemonic.newWith(entropy: randomEntropy);
            final mnemonicWords = mnemonic.asWords();
            logger.d("Recovery Mnemonic: $mnemonicWords");
            final recoveryPassword = randomEntropy.base64encode();

            final hashedPassword = await SrpClient.computeKeyPassword(
              password: recoveryPassword,
              salt: salt,
            );

            final userFirstKey = await userManager.getPrimaryKey();
            final userKeys = userInfo.keys;
            if (userKeys == null) {
              return Future.error('User keys not found');
            }
            // if (userKeys.length != 1) {
            //   return Future.error('More then one key is not supported yet');
            // }

            final oldPassphrase = userFirstKey.passphrase;

            final List<MnemonicUserKey> mnUserKeys = [];

            /// reencrypt password for now only support one
            for (ProtonUserKey key in userKeys) {
              final newKey = proton_crypto.changePrivateKeyPassword(
                key.privateKey,
                oldPassphrase,
                hashedPassword,
              );
              mnUserKeys.add(MnemonicUserKey(id: key.id, privateKey: newKey));
            }

            /// get srp module
            final serverModule = await protonUsersApi.getAuthModule();

            /// get clear text and verify signature
            final SRPVerifierB64 verifier = await SrpClient.generateVerifer(
              password: recoveryPassword,
              serverModulus: serverModule.modulus,
            );

            final auth = MnemonicAuth(
              modulusId: serverModule.modulusId,
              salt: verifier.salt,
              version: verifier.version,
              verifier: verifier.verifier,
            );

            final req = UpdateMnemonicSettingsRequestBody(
              mnemonicUserKeys: mnUserKeys,
              mnemonicSalt: salt.base64encode(),
              mnemonicAuth: auth,
            );
            final recoveryCode =
                await protonSettingsApi.setMnemonicSettings(req: req);
            logger.i("EnableRecovery response code: $recoveryCode");
            final lockCode = await protonUsersApi.lockSensitiveSettings();
            if (recoveryCode != 1000) {
              emit(state.copyWith(
                isLoading: false,
                requireAuthModel: const RequireAuthModel(),
                error:
                    "Eanble recovery failed, please try again. code: $recoveryCode",
              ));
              return;
            }
            logger.i("EnableRecovery lockSensitiveSettings: $lockCode");
            if (lockCode != 1000) {
              emit(state.copyWith(
                isLoading: false,
                requireAuthModel: const RequireAuthModel(),
                error:
                    "Eanble recovery failed, please try again. code: $lockCode",
              ));
              return;
            }
            userDataProvider.enabledRecovery(true);
            emit(state.copyWith(
                isLoading: false,
                error: "",
                isRecoveryEnabled: true,
                requireAuthModel: const RequireAuthModel(),
                mnemonic: mnemonicWords.join(" ")));
          } on BridgeError catch (e) {
            final errorMessage = parseSampleDisplayError(e);
            emit(state.copyWith(
                isLoading: false,
                requireAuthModel: const RequireAuthModel(),
                error: errorMessage));
          } catch (e) {
            emit(state.copyWith(
                isLoading: false,
                requireAuthModel: const RequireAuthModel(),
                error: e.toString()));
          }
        }

        /// set mnemonic
      } else if (status == 2 || status == 4) {
        /// reactive flow
        /// generate new entropy and mnemonic
        final salt = WalletKeyHelper.getRandomValues(16);
        final randomEntropy = WalletKeyHelper.getRandomValues(16);

        final FrbMnemonic mnemonic =
            FrbMnemonic.newWith(entropy: randomEntropy);
        final mnemonicWords = mnemonic.asWords();
        logger.d("Recovery Mnemonic: $mnemonicWords");
        final recoveryPassword = randomEntropy.base64encode();

        final hashedPassword = await SrpClient.computeKeyPassword(
          password: recoveryPassword,
          salt: salt,
        );

        final userFirstKey = await userManager.getPrimaryKey();
        final userKeys = userInfo.keys;
        if (userKeys == null) {
          return Future.error('User keys not found');
        }
        // if (userKeys.length != 1) {
        //   return Future.error('More then one key is not supported yet');
        // }

        final oldPassphrase = userFirstKey.passphrase;

        final List<MnemonicUserKey> mnUserKeys = [];

        /// reencrypt password for now only support one
        for (ProtonUserKey key in userKeys) {
          final newKey = proton_crypto.changePrivateKeyPassword(
            key.privateKey,
            oldPassphrase,
            hashedPassword,
          );
          mnUserKeys.add(MnemonicUserKey(id: key.id, privateKey: newKey));
        }

        try {
          /// get srp module
          final serverModule = await protonUsersApi.getAuthModule();

          /// get clear text and verify signature
          final SRPVerifierB64 verifier = await SrpClient.generateVerifer(
            password: recoveryPassword,
            serverModulus: serverModule.modulus,
          );

          final auth = MnemonicAuth(
            modulusId: serverModule.modulusId,
            salt: verifier.salt,
            version: verifier.version,
            verifier: verifier.verifier,
          );

          final req = UpdateMnemonicSettingsRequestBody(
            mnemonicUserKeys: mnUserKeys,
            mnemonicSalt: salt.base64encode(),
            mnemonicAuth: auth,
          );

          final code =
              await protonSettingsApi.reactiveMnemonicSettings(req: req);
          logger.i("EnableRecovery response code: $code");
          if (code != 1000) {
            emit(state.copyWith(
              isLoading: false,
              requireAuthModel: const RequireAuthModel(),
              error: "Eanble recovery failed, please try again. code: $code",
            ));
            return;
          }
          userDataProvider.enabledRecovery(true);
          emit(state.copyWith(
              isLoading: false,
              error: "",
              isRecoveryEnabled: true,
              requireAuthModel: const RequireAuthModel(),
              mnemonic: mnemonicWords.join(" ")));
        } on BridgeError catch (e) {
          final errorMessage = parseSampleDisplayError(e);
          emit(state.copyWith(
              isLoading: false,
              requireAuthModel: const RequireAuthModel(),
              error: errorMessage));
        } catch (e) {
          emit(state.copyWith(
              isLoading: false,
              requireAuthModel: const RequireAuthModel(),
              error: e.toString()));
        }
      }

      /// build random srp verifier.
    });

    on<DisableRecovery>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: ""));

      if (event.step == RecoverySteps.start) {
        // var status = userInfo.mnemonicStatus;
        // check if the status is disabled already skip the process
        /// get auth info
        final authInfo = await protonUsersApi.getAuthInfo(intent: "Proton");

        /// 0 for disabled, 1 for OTP, 2 for FIDO2, 3 for both
        final twoFaEnable = authInfo.twoFa.enabled;
        final authSetp = RequireAuthModel(
            requireAuth: true, twofaStatus: twoFaEnable, isDisable: true);
        emit(state.copyWith(requireAuthModel: authSetp, authInfo: authInfo));
      } else if (event.step == RecoverySteps.auth) {
        final loginPassword = event.password;
        final loginTwoFa = event.twofa;
        final authInfo = state.authInfo ??
            await protonUsersApi.getAuthInfo(intent: "Proton");

        /// build srp client proof
        final clientProofs = await SrpClient.generateProofs(
            loginPassword: loginPassword,
            version: authInfo.version,
            salt: authInfo.salt,
            modulus: authInfo.modulus,
            serverEphemeral: authInfo.serverEphemeral);

        final proofs = authInfo.twoFa.enabled == 1
            ? ProtonSrpClientProofs(
                clientEphemeral: clientProofs.clientEphemeral,
                clientProof: clientProofs.clientProof,
                srpSession: authInfo.srpSession,
                twoFactorCode: loginTwoFa)
            : ProtonSrpClientProofs(
                clientEphemeral: clientProofs.clientEphemeral,
                clientProof: clientProofs.clientProof,
                srpSession: authInfo.srpSession);

        try {
          /// build request
          final serverProofs = await protonSettingsApi.disableMnemonicSettings(
            proofs: proofs,
          );

          /// check if the server proofs are valid
          final check = clientProofs.expectedServerProof == serverProofs;
          logger.i("DisableRecovery server proofs: $check");
          userDataProvider.enabledRecovery(false);
          emit(state.copyWith(
              isLoading: false,
              isRecoveryEnabled: false,
              requireAuthModel: const RequireAuthModel()));
        } on BridgeError catch (e) {
          final errorMessage = parseSampleDisplayError(e);
          emit(state.copyWith(
              isLoading: false,
              requireAuthModel: const RequireAuthModel(),
              error: errorMessage));
        } catch (e) {
          emit(state.copyWith(
              isLoading: false,
              requireAuthModel: const RequireAuthModel(),
              error: e.toString()));
        }
      } else {}
    });
  }

  Future<void> enableRecovery() async {}

  Future<void> disableRecovery() async {}
}

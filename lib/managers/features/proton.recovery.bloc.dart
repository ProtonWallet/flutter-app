import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/constants/constants.dart';
import 'package:wallet/managers/users/user.manager.dart';
import 'package:wallet/rust/api/api_service/proton_users_client.dart';
import 'package:proton_crypto/proton_crypto.dart' as proton_crypto;
import 'package:wallet/rust/proton_api/proton_users.dart';

// Define the events
abstract class ProtonRecoveryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

// Define the state
class ProtonRecoveryState extends Equatable {
  @override
  List<Object?> get props => [];
}

extension CreatingWalletState on ProtonRecoveryState {}

extension AddingEmailState on ProtonRecoveryState {}

/// Define the Bloc
class ProtonRecoveryBloc
    extends Bloc<ProtonRecoveryEvent, ProtonRecoveryState> {
  final UserManager userManager;
  final ProtonUsersClient protonUsersApi;

  /// initialize the bloc with the initial state
  ProtonRecoveryBloc(
    this.userManager,
    this.protonUsersApi,
  ) : super(ProtonRecoveryState()) {
    on<ProtonRecoveryEvent>((event, emit) async {});
  }

  Future<void> enableRecovery() async {
    // get user info
    var userInfo = await protonUsersApi.getUserInfo();
    var userKeys = userInfo.keys;
    if (userKeys == null) {
      return Future.error('User keys not found');
    }
    if (userKeys.length != 1) {
      return Future.error('More then one key is not supported yet');
    }

    var status = userInfo.mnemonicStatus;
    if (status == 0) {
      /// set new flow
      /// get auth info
      var authinfo = await protonUsersApi.getAuthInfo(intent: "Proton");

      /// 0 for disabled, 1 for OTP, 2 for FIDO2, 3 for both
      if (authinfo.twoFa.enabled != 0) {
        /// ask 2fa view
      }

      /// ask user login password
      var password = "12345678";

      /// password scop unlock password change
      ProtonSrpClientProofs proofs = const ProtonSrpClientProofs(
          clientEphemeral: '', clientProof: '', srpSession: '');
      var serverProofs =
          await protonUsersApi.unlockPasswordChange(proofs: proofs);

      /// get srp module
      var module = await protonUsersApi.getAuthModule();

      /// get clear text and verify signature
      var check = proton_crypto.verifyCleartextMessageArmored(
          srpModulusKey, module.modulus);

      /// reencrypt password for now only support one
      for (ProtonUserKey key in userKeys) {
        // var decrypted = proton_crypto.decryptMessage(
        //     key.key, serverProofs.srpSession, key.iv);
        // var encrypted =
        //     proton_crypto.encryptMessage(key.key, decrypted, key.iv, key.salt);
        // key.key = encrypted;
      }

      /// set mnemonic
    } else if (status == 1 || status == 2 || status == 4) {
      /// reactive flow
      /// get srp module
      var module = await protonUsersApi.getAuthModule();

      /// get clear text and verify signature
      var check = proton_crypto.verifyCleartextMessageArmored(
          srpModulusKey, module.modulus);

      if (!check.verified) {
        return Future.error('Invalid modulus');
      }
    }

    /// build random srp verifier.

    return Future.value();
  }

  Future<void> disableRecovery() async {
    return Future.value();
  }
}

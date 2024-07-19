import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/logger.dart';
import 'package:wallet/managers/providers/wallet.data.provider.dart';
import 'package:wallet/models/account.model.dart';
import 'package:wallet/models/wallet.model.dart';
import 'package:wallet/rust/api/api_service/proton_users_client.dart';
import 'package:wallet/rust/api/api_service/wallet_client.dart';
import 'package:wallet/rust/api/srp/srp_client.dart';
import 'package:wallet/rust/common/errors.dart';
import 'package:wallet/rust/proton_api/proton_users.dart';

/// recovery steps
enum DeleteWalletSteps {
  start,
  auth,
}

/// Define the events
class DeleteWalletEvent extends Equatable {
  final WalletModel walletModel;
  final DeleteWalletSteps step;
  final String password;
  final String twofa;

  const DeleteWalletEvent(
    this.walletModel,
    this.step, {
    this.password = "",
    this.twofa = "",
  });

  @override
  List<Object> get props => [walletModel];
}

/// model
class DeleteWalletAuthModel {
  final bool requireAuth;
  final int twofaStatus;
  const DeleteWalletAuthModel({
    this.requireAuth = false,
    this.twofaStatus = 0,
  });
}

///
class DeleteWalletState extends Equatable {
  final bool isLoading;
  final bool deleted;
  final String error;
  final DeleteWalletAuthModel requireAuthModel;
  final GetAuthInfoResponseBody? authInfo;

  const DeleteWalletState({
    this.isLoading = false,
    this.deleted = false,
    this.requireAuthModel = const DeleteWalletAuthModel(),
    this.error = "",
    this.authInfo,
  });

  DeleteWalletState copyWith({
    bool? isLoading,
    bool? deleted,
    String? error,
    DeleteWalletAuthModel? requireAuthModel,
    GetAuthInfoResponseBody? authInfo,
  }) {
    return DeleteWalletState(
      isLoading: isLoading ?? this.isLoading,
      deleted: deleted ?? this.deleted,
      requireAuthModel: requireAuthModel ?? this.requireAuthModel,
      authInfo: authInfo,
      error: error ?? this.error,
    );
  }

  @override
  List<Object> get props => [
        isLoading,
        requireAuthModel,
        error,
      ];
}

/// Define the Bloc
class DeleteWalletBloc extends Bloc<DeleteWalletEvent, DeleteWalletState> {
  final WalletsDataProvider walletsDataProvider;
  final ProtonUsersClient protonUsersApi;

  /// wallet api
  final WalletClient walletClient;

  /// initialize the bloc with the initial state
  DeleteWalletBloc(
    this.walletsDataProvider,
    this.walletClient,
    this.protonUsersApi,
  ) : super(const DeleteWalletState()) {
    on<DeleteWalletEvent>((event, emit) async {
      emit(state.copyWith(
          isLoading: true,
          error: "",
          deleted: false,
          requireAuthModel: const DeleteWalletAuthModel()));

      if (event.step == DeleteWalletSteps.start) {
        try {
          final authInfo = await protonUsersApi.getAuthInfo(intent: "Proton");

          /// 0 for disabled, 1 for OTP, 2 for FIDO2, 3 for both
          final twoFaEnable = authInfo.twoFa.enabled;
          final authSetp = DeleteWalletAuthModel(
            requireAuth: true,
            twofaStatus: twoFaEnable,
          );
          emit(state.copyWith(
            isLoading: false,
            requireAuthModel: authSetp,
            authInfo: authInfo,
          ));
        } on BridgeError catch (e, stacktrace) {
          final errorMessage = parseSampleDisplayError(e);
          logger.e("Delete wallet BridgeError: $e, stacktrace: $stacktrace");
          emit(state.copyWith(
              isLoading: false,
              requireAuthModel: const DeleteWalletAuthModel(),
              error: errorMessage));
        } catch (e, stacktrace) {
          logger.e("Delete wallet error: $e, stacktrace: $stacktrace");
          final errorMessage = e.toString();
          emit(state.copyWith(
              isLoading: false,
              requireAuthModel: const DeleteWalletAuthModel(),
              error: errorMessage));
        }
      } else if (event.step == DeleteWalletSteps.auth) {
        try {
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

          final serverProofs = await protonUsersApi.unlockPasswordChange(
            proofs: proofs,
          );

          /// check if the server proofs are valid
          final check = clientProofs.expectedServerProof == serverProofs;
          logger.i("Delete wallet password server proofs: $check");
          if (!check) {
            return Future.error('Invalid server proofs');
          }

          await walletClient.deleteWallet(walletId: event.walletModel.walletID);
          await walletsDataProvider.deleteWallet(wallet: event.walletModel);

          emit(state.copyWith(
              isLoading: false,
              error: "",
              deleted: true,
              requireAuthModel: const DeleteWalletAuthModel()));

          final lockCode = await protonUsersApi.lockSensitiveSettings();
          logger.i("Delete wallet password lockSensitiveSettings: $lockCode");
        } on BridgeError catch (e, stacktrace) {
          final errorMessage = parseSampleDisplayError(e);
          logger.e("Delete wallet BridgeError: $e, stacktrace: $stacktrace");
          emit(state.copyWith(
              isLoading: false,
              requireAuthModel: const DeleteWalletAuthModel(),
              error: errorMessage));
        } catch (e, stacktrace) {
          logger.e("Delete wallet error: $e, stacktrace: $stacktrace");
          final errorMessage = e.toString();
          emit(state.copyWith(
              isLoading: false,
              requireAuthModel: const DeleteWalletAuthModel(),
              error: errorMessage));
        }
      }
    });
  }

  Future<void> deleteWalletAccount(
    String walletID,
    AccountModel accountModel,
  ) async {
    try {
      await walletClient.deleteWalletAccount(
        walletId: walletID,
        walletAccountId: accountModel.accountID,
      );
      await walletsDataProvider.deleteWalletAccount(accountModel: accountModel);
    } on BridgeError catch (e, stacktrace) {
      // errorMessage = parseSampleDisplayError(e);
      logger.e("importWallet BridgeError: $e, stacktrace: $stacktrace");
    } catch (e, stacktrace) {
      logger.e("importWallet error: $e, stacktrace: $stacktrace");
      // errorMessage = e.toString();
    }
  }
}

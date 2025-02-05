import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet/helper/exceptions.dart';
import 'package:wallet/helper/extension/response.error.extension.dart';
import 'package:wallet/managers/app.state.manager.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.event.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.state.dart';
import 'package:wallet/managers/providers/user.data.provider.dart';
import 'package:wallet/rust/api/errors.dart';
import 'package:wallet/rust/api/proton_wallet/features/proton_recovery.dart';

/// Define the Bloc
class ProtonRecoveryBloc
    extends Bloc<ProtonRecoveryEvent, ProtonRecoveryState> {
  final UserDataProvider userDataProvider;

  /// rust features
  final FrbProtonRecovery frbProtonRecovery;

  /// app state
  final AppStateManager appStateManager;

  /// initialize the bloc with the initial state
  ProtonRecoveryBloc(
    this.userDataProvider,
    this.appStateManager,
    this.frbProtonRecovery,
  ) : super(const ProtonRecoveryState()) {
    on<LoadingRecovery>((event, emit) async {
      emit(state.copyWith(
        isLoading: true,
        error: "",
        isRecoveryEnabled: false,
        mnemonic: "",
        requireAuthModel: const RequireAuthModel(),
      ));
      final frbStatus = await frbProtonRecovery.recoveryStatus();
      final status = frbStatus == 3;

      emit(state.copyWith(
        isLoading: false,
        isRecoveryEnabled: status,
      ));
    });

    on<TestRecovery>((event, emit) async {
      emit(state.copyWith(
        isLoading: true,
        error: "",
        isRecoveryEnabled: false,
        mnemonic:
            "banner tag desk cart mirror horse name minimum hen sport sadness evidence",
        requireAuthModel: const RequireAuthModel(),
      ));
      final frbStatus = await frbProtonRecovery.recoveryStatus();
      final status = frbStatus == 3;
      emit(state.copyWith(isLoading: false, isRecoveryEnabled: status));
    });

    on<EnableRecovery>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: ""));
      final status = await frbProtonRecovery.recoveryStatus();
      // 0 - Mnemonic is disabled
      // 1 - Mnemonic is enabled but not set
      // 2 - Mnemonic is enabled but needs to be re-activated
      // 3 - Mnemonic is enabled and set
      if (status == 0 || status == 1) {
        // enable recovery flow
        if (event.step == RecoverySteps.start) {
          // check if the status is disabled already skip the process
          /// 0 for disabled, 1 for OTP, 2 for FIDO2, 3 for both
          final twoFaEnable = await frbProtonRecovery.twoFaStatus();
          final authSetp = RequireAuthModel(
            requireAuth: true,
            twofaStatus: twoFaEnable,
          );
          emit(state.copyWith(requireAuthModel: authSetp));
        } else if (event.step == RecoverySteps.auth) {
          final loginPassword = event.password;
          final loginTwoFa = event.twofa;
          try {
            final mnemonicWords = await frbProtonRecovery.enableRecovery(
              loginPassword: loginPassword,
              twofa: loginTwoFa,
            );
            userDataProvider.enabledRecovery(true);
            emit(state.copyWith(
                isLoading: false,
                error: "",
                isRecoveryEnabled: true,
                requireAuthModel: const RequireAuthModel(),
                mnemonic: mnemonicWords.join(" ")));
          } on BridgeError catch (e) {
            final errorMessage = parseSampleDisplayError(e);
            appStateManager.updateStateFrom(e);
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
      } else if (status == 2 || status == 4) {
        /// reactive flow
        try {
          try {
            List<String> mnemonicWords;
            if (event.step == RecoverySteps.auth) {
              final loginPassword = event.password;
              final loginTwoFa = event.twofa;
              mnemonicWords = await frbProtonRecovery.reactiveRecovery(
                loginPassword: loginPassword,
                twofa: loginTwoFa,
              );
            } else {
              mnemonicWords = await frbProtonRecovery.reactiveRecovery(
                twofa: "",
              );
            }
            userDataProvider.enabledRecovery(true);
            emit(state.copyWith(
              isLoading: false,
              error: "",
              isRecoveryEnabled: true,
              requireAuthModel: const RequireAuthModel(),
              mnemonic: mnemonicWords.join(" "),
            ));
          } on BridgeError catch (e) {
            final apiError = parseResponseError(e);
            if (apiError != null &&
                apiError.isMissingLockedScope() &&
                event.step != RecoverySteps.auth) {
              /// 0 for disabled, 1 for OTP, 2 for FIDO2, 3 for both
              final twoFaEnable = await frbProtonRecovery.twoFaStatus();
              emit(state.copyWith(
                requireAuthModel: RequireAuthModel(
                  requireAuth: true,
                  twofaStatus: twoFaEnable,
                ),
              ));
              return;
            }
            rethrow;
          } catch (e) {
            rethrow;
          }
        } on BridgeError catch (e) {
          appStateManager.updateStateFrom(e);
          final errorMessage = parseSampleDisplayError(e);
          emit(state.copyWith(
            isLoading: false,
            requireAuthModel: const RequireAuthModel(),
            error: errorMessage,
          ));
        } catch (e) {
          emit(state.copyWith(
            isLoading: false,
            requireAuthModel: const RequireAuthModel(),
            error: e.toString(),
          ));
        }
      }
    });

    on<DisableRecovery>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: ""));
      if (event.step == RecoverySteps.start) {
        // check if the status is disabled already skip the process
        /// 0 for disabled, 1 for OTP, 2 for FIDO2, 3 for both
        final twoFaEnable = await frbProtonRecovery.twoFaStatus();
        final authSetp = RequireAuthModel(
          requireAuth: true,
          twofaStatus: twoFaEnable,
          isDisable: true,
        );
        emit(state.copyWith(requireAuthModel: authSetp));
      } else if (event.step == RecoverySteps.auth) {
        final loginPassword = event.password;
        final loginTwoFa = event.twofa;
        try {
          await frbProtonRecovery.disableRecovery(
            loginPassword: loginPassword,
            twofa: loginTwoFa,
          );
          bool enabledRecovery = false;

          /// check if user has enable device recovery, which is consider as other recovery method
          if (userDataProvider.user.protonUserSettings != null) {
            if (userDataProvider.user.protonUserSettings!.deviceRecovery == 1) {
              enabledRecovery = true;
            }
          }
          userDataProvider.enabledRecovery(enabledRecovery);
          emit(state.copyWith(
            isLoading: false,
            isRecoveryEnabled: false,
            requireAuthModel: const RequireAuthModel(),
          ));
        } on BridgeError catch (e) {
          appStateManager.updateStateFrom(e);
          final errorMessage = parseSampleDisplayError(e);
          emit(state.copyWith(
            isLoading: false,
            requireAuthModel: const RequireAuthModel(),
            error: errorMessage,
          ));
        } catch (e) {
          emit(state.copyWith(
            isLoading: false,
            requireAuthModel: const RequireAuthModel(),
            error: e.toString(),
          ));
        }
      }
    });
  }
}

import 'package:equatable/equatable.dart';
import 'package:wallet/managers/features/proton.recovery/proton.recovery.state.dart';
import 'package:wallet/rust/proton_api/proton_users.dart';

class ProtonTwoFaState extends Equatable {
  final bool isLoading;
  final bool isRecoveryEnabled;
  final String error;
  final String mnemonic;

  final RequireAuthModel requireAuthModel;
  final GetAuthInfoResponseBody? authInfo;

  const ProtonTwoFaState({
    this.isLoading = false,
    this.isRecoveryEnabled = false,
    this.requireAuthModel = const RequireAuthModel(),
    this.error = "",
    this.mnemonic = "",
    this.authInfo,
  });

  ProtonTwoFaState copyWith({
    bool? isLoading,
    bool? isRecoveryEnabled,
    String? error,
    RequireAuthModel? requireAuthModel,
    GetAuthInfoResponseBody? authInfo,
    String? mnemonic,
  }) {
    return ProtonTwoFaState(
      isLoading: isLoading ?? this.isLoading,
      isRecoveryEnabled: isRecoveryEnabled ?? this.isRecoveryEnabled,
      requireAuthModel: requireAuthModel ?? this.requireAuthModel,
      authInfo: authInfo,
      error: error ?? this.error,
      mnemonic: mnemonic ?? this.mnemonic,
    );
  }

  @override
  List<Object> get props => [
        isLoading,
        isRecoveryEnabled,
        requireAuthModel,
        error,
        mnemonic,
      ];
}

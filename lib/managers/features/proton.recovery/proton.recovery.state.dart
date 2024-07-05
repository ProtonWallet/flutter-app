// Define the state
import 'package:equatable/equatable.dart';
import 'package:wallet/rust/proton_api/proton_users.dart';

class RequireAuthModel {
  final bool requireAuth;
  final int twofaStatus;
  final bool isDisable;
  const RequireAuthModel({
    this.requireAuth = false,
    this.twofaStatus = 0,
    this.isDisable = false,
  });
}

class ProtonRecoveryState extends Equatable {
  final bool isLoading;
  final bool isRecoveryEnabled;
  final String error;
  final String mnemonic;

  final RequireAuthModel requireAuthModel;
  final GetAuthInfoResponseBody? authInfo;

  const ProtonRecoveryState({
    this.isLoading = false,
    this.isRecoveryEnabled = false,
    this.requireAuthModel = const RequireAuthModel(),
    this.error = "",
    this.mnemonic = "",
    this.authInfo,
  });

  ProtonRecoveryState copyWith({
    bool? isLoading,
    bool? isRecoveryEnabled,
    String? error,
    RequireAuthModel? requireAuthModel,
    GetAuthInfoResponseBody? authInfo,
    String? mnemonic,
  }) {
    return ProtonRecoveryState(
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

extension CreatingWalletState on ProtonRecoveryState {}

extension AddingEmailState on ProtonRecoveryState {}

/// recovery steps
enum RecoverySteps {
  start,
  auth,
}

/// user mnemonic status
enum MnemonicStatus {
  disabled,
  enabled,
  outdated,
  set,
  prompt,
}

extension MnemonicStatusExtension on MnemonicStatus {
  static MnemonicStatus fromInt(int value) {
    switch (value) {
      case 0:
        return MnemonicStatus.disabled;
      case 1:
        return MnemonicStatus.enabled;
      case 2:
        return MnemonicStatus.outdated;
      case 3:
        return MnemonicStatus.set;
      case 4:
        return MnemonicStatus.prompt;
      default:
        throw ArgumentError('Invalid enum value: $value');
    }
  }

  int toInt() {
    return index;
  }
}

// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.24.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'package:freezed_annotation/freezed_annotation.dart' hide protected;
part 'error.freezed.dart';

@freezed
sealed class Error with _$Error implements FrbException {
  const factory Error.accountNotFound() = Error_AccountNotFound;
  const factory Error.bdkError(
    String field0,
  ) = Error_BdkError;
  const factory Error.bip32Error(
    String field0,
  ) = Error_Bip32Error;
  const factory Error.bip39Error(
    String field0,
  ) = Error_Bip39Error;
  const factory Error.cannotBroadcastTransaction() =
      Error_CannotBroadcastTransaction;
  const factory Error.cannotComputeTxFees() = Error_CannotComputeTxFees;
  const factory Error.cannotGetFeeEstimation() = Error_CannotGetFeeEstimation;
  const factory Error.cannotCreateAddressFromScript() =
      Error_CannotCreateAddressFromScript;
  const factory Error.cannotGetAddressFromScript() =
      Error_CannotGetAddressFromScript;
  const factory Error.derivationError() = Error_DerivationError;
  const factory Error.descriptorError(
    String field0,
  ) = Error_DescriptorError;
  const factory Error.invalidAccountIndex() = Error_InvalidAccountIndex;
  const factory Error.invalidAddress() = Error_InvalidAddress;
  const factory Error.invalidData() = Error_InvalidData;
  const factory Error.invalidDescriptor() = Error_InvalidDescriptor;
  const factory Error.invalidDerivationPath() = Error_InvalidDerivationPath;
  const factory Error.invalidNetwork() = Error_InvalidNetwork;
  const factory Error.invalidTxId() = Error_InvalidTxId;
  const factory Error.invalidScriptType() = Error_InvalidScriptType;
  const factory Error.invalidSecretKey() = Error_InvalidSecretKey;
  const factory Error.invalidMnemonic() = Error_InvalidMnemonic;
  const factory Error.loadError() = Error_LoadError;
  const factory Error.syncError() = Error_SyncError;
  const factory Error.transactionNotFound() = Error_TransactionNotFound;
}
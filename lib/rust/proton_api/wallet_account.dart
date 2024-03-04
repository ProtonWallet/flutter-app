// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.24.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class CreateWalletAccountReq {
  final String label;
  final String derivationPath;
  final int scriptType;

  const CreateWalletAccountReq({
    required this.label,
    required this.derivationPath,
    required this.scriptType,
  });

  @override
  int get hashCode =>
      label.hashCode ^ derivationPath.hashCode ^ scriptType.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateWalletAccountReq &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          derivationPath == other.derivationPath &&
          scriptType == other.scriptType;
}

class WalletAccount {
  final String id;
  final String walletId;
  final String derivationPath;
  final String label;
  final int scriptType;

  const WalletAccount({
    required this.id,
    required this.walletId,
    required this.derivationPath,
    required this.label,
    required this.scriptType,
  });

  @override
  int get hashCode =>
      id.hashCode ^
      walletId.hashCode ^
      derivationPath.hashCode ^
      label.hashCode ^
      scriptType.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WalletAccount &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          walletId == other.walletId &&
          derivationPath == other.derivationPath &&
          label == other.label &&
          scriptType == other.scriptType;
}
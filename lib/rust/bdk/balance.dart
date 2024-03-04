// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0-dev.24.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

class Balance {
  final int immature;

  /// Unconfirmed UTXOs generated by a wallet tx
  final int trustedPending;

  /// Unconfirmed UTXOs received from an external wallet
  final int untrustedPending;

  /// Confirmed and immediately spendable balance
  final int confirmed;

  /// Get sum of trusted_pending and confirmed coins
  final int spendable;

  /// Get the whole balance visible to the wallet
  final int total;

  const Balance({
    required this.immature,
    required this.trustedPending,
    required this.untrustedPending,
    required this.confirmed,
    required this.spendable,
    required this.total,
  });

  @override
  int get hashCode =>
      immature.hashCode ^
      trustedPending.hashCode ^
      untrustedPending.hashCode ^
      confirmed.hashCode ^
      spendable.hashCode ^
      total.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Balance &&
          runtimeType == other.runtimeType &&
          immature == other.immature &&
          trustedPending == other.trustedPending &&
          untrustedPending == other.untrustedPending &&
          confirmed == other.confirmed &&
          spendable == other.spendable &&
          total == other.total;
}
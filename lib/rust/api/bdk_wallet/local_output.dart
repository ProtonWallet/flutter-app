// This file is automatically generated, so please do not edit it.
// @generated by `flutter_rust_bridge`@ 2.6.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../../common/keychain_kind.dart';
import '../../frb_generated.dart';
import 'amount.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';
import 'script_buf.dart';

// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `assert_receiver_is_total_eq`, `clone`, `clone`, `clone`, `cmp`, `cmp`, `eq`, `eq`, `eq`, `fmt`, `fmt`, `fmt`, `from`, `from`, `from`, `hash`, `hash`, `hash`, `partial_cmp`, `partial_cmp`

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<FrbLocalOutput>>
abstract class FrbLocalOutput implements RustOpaqueInterface {
  int get derivationIndex;

  bool get isSpent;

  KeychainKind get keychain;

  FrbOutPoint get outpoint;

  FrbTxOut get txout;
}

// Rust type: RustOpaqueMoi<flutter_rust_bridge::for_generated::RustAutoOpaqueInner<FrbTxOut>>
abstract class FrbTxOut implements RustOpaqueInterface {
  FrbScriptBuf get scriptPubkey;

  FrbAmount get value;
}

class FrbOutPoint {
  /// The referenced transaction's txid.
  final String txid;

  /// The index of the referenced output in its transaction's vout.
  final int vout;

  const FrbOutPoint({
    required this.txid,
    required this.vout,
  });

  @override
  int get hashCode => txid.hashCode ^ vout.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrbOutPoint &&
          runtimeType == other.runtimeType &&
          txid == other.txid &&
          vout == other.vout;
}
